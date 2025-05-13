import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    logs_client = boto3.client('logs')
    evaluations = []

    excluded_log_groups = valid_rule_parameters.get('ExcludedLogGroups', '').split(',')

    log_groups = logs_client.describe_log_groups()['logGroups']
    for log_group in log_groups:
        log_group_name = log_group['logGroupName']
        retention_in_days = log_group.get('retentionInDays')

        if log_group_name in excluded_log_groups:
            evaluations.append(build_evaluation(log_group_name, 'COMPLIANT', event, annotation='This log group is excluded from the check.'))
            continue

        if retention_in_days is not None and retention_in_days < 365:
            evaluations.append(build_evaluation(log_group_name, 'NON_COMPLIANT', event, annotation='Retention period is less than 365 days.'))
        else:
            evaluations.append(build_evaluation(log_group_name, 'COMPLIANT', event))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::Logs::LogGroup',
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
