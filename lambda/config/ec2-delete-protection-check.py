import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    ec2_client = boto3.client('ec2')
    evaluations = []
    excluded_ec2s = valid_rule_parameters.get('ExcludedEC2s', '').split(',')

    paginator = ec2_client.get_paginator('describe_instances')
    page_iterator = paginator.paginate()

    for page in page_iterator:
        for reservation in page['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']

                # 태그 기반 예외 처리
                name_tag = next((tag['Value'] for tag in instance.get('Tags', []) if tag['Key'] == 'Name'), '')
                if (
                    instance_id in excluded_ec2s or
                    'ap-northeast-2.compute.internal' in name_tag or
                    'ekslt-esp' in name_tag
                ):
                    evaluations.append(build_evaluation(instance_id, 'COMPLIANT', event, annotation='This instance is excluded from the check.'))
                    continue

                try:
                    attr = ec2_client.describe_instance_attribute(
                        InstanceId=instance_id,
                        Attribute='disableApiTermination'
                    )
                    is_protected = attr.get('DisableApiTermination', {}).get('Value', False)

                    if is_protected:
                        evaluations.append(build_evaluation(instance_id, 'COMPLIANT', event))
                    else:
                        evaluations.append(build_evaluation(instance_id, 'NON_COMPLIANT', event, annotation='Termination protection is disabled.'))

                except Exception as e:
                    evaluations.append(build_evaluation(instance_id, 'NON_COMPLIANT', event, annotation=f'Error checking instance: {str(e)}'))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::EC2::Instance',
        'ComplianceResourceId': resource_id,
        'ComplianceType': compliance_type,
        'OrderingTimestamp': str(json.loads(event['invokingEvent'])['notificationCreationTime'])
    }
    if annotation:
        evaluation['Annotation'] = annotation
    return evaluation

def lambda_handler(event, context):
    invoking_event = json.loads(event['invokingEvent'])
    rule_parameters = json.loads(event.get('ruleParameters', '{}'))
    configuration_item = invoking_event.get('configurationItem')
    evaluations = evaluate_compliance(event, configuration_item, rule_parameters)

    config_client = boto3.client('config')
    result_token = event['resultToken']
    test_mode = result_token == 'TESTMODE'
    config_client.put_evaluations(
        Evaluations=evaluations,
        ResultToken=result_token,
        TestMode=test_mode
    )