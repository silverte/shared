import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    rds_client = boto3.client('rds')
    evaluations = []
    excluded_rds_ids = valid_rule_parameters.get('ExcludedRDSs', '').split(',')

    paginator = rds_client.get_paginator('describe_db_instances')
    page_iterator = paginator.paginate()

    for page in page_iterator:
        for db_instance in page['DBInstances']:
            db_identifier = db_instance['DBInstanceIdentifier']

            # Aurora 제외 (Aurora는 Engine에 'aurora'가 포함되어 있음)
            if 'aurora' in db_instance['Engine'].lower():
                continue

            if db_identifier in excluded_rds_ids:
                evaluations.append(build_evaluation(db_identifier, 'COMPLIANT', event, annotation='This RDS is excluded from the check.'))
                continue

            is_multi_az = db_instance.get('MultiAZ', False)
            if is_multi_az:
                evaluations.append(build_evaluation(db_identifier, 'COMPLIANT', event))
            else:
                evaluations.append(build_evaluation(db_identifier, 'NON_COMPLIANT', event, annotation='Multi-AZ deployment is not enabled.'))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::RDS::DBInstance',
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
