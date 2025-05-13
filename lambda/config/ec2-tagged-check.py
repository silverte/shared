import json
import boto3
from datetime import datetime, timezone

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    ec2_client = boto3.client('ec2')
    evaluations = []
    excluded_ec2s = valid_rule_parameters.get('ExcludedEC2s', '').split(',')
    tag_keys_to_check = valid_rule_parameters.get('CheckTagKeys', '').split(',')

    # Describe all EC2 instances
    paginator = ec2_client.get_paginator('describe_instances')
    page_iterator = paginator.paginate()

    for page in page_iterator:
        for reservation in page['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                if instance_id in excluded_ec2s:
                    evaluations.append(build_evaluation(instance_id, 'COMPLIANT', event, annotation='This instance is excluded from the check.'))
                    continue

                instance_tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                missing_tags = [key for key in tag_keys_to_check if key not in instance_tags]

                if missing_tags:
                    evaluations.append(build_evaluation(
                        instance_id,
                        'NON_COMPLIANT',
                        event,
                        annotation=f'Missing tag keys: {", ".join(missing_tags)}'
                    ))
                else:
                    evaluations.append(build_evaluation(instance_id, 'COMPLIANT', event))

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
