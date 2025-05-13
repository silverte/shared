import json
import boto3
from datetime import datetime, timedelta, timezone

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    iam_client = boto3.client('iam')
    evaluations = []
    threshold_date = datetime.now(timezone.utc) - timedelta(days=90)
    excluded_roles = valid_rule_parameters.get('ExcludedRoles', '').split(',')

    roles = iam_client.list_roles()['Roles']
    for role in roles:
        role_name = role['RoleName']
        role_id = role['RoleId']
        if role_name in excluded_roles:
            evaluations.append(build_evaluation(role_id, 'COMPLIANT', event, annotation='This role is excluded from the check.'))
            continue

        role_details = iam_client.get_role(RoleName=role_name)
        last_used = role_details.get('Role', {}).get('RoleLastUsed', {}).get('LastUsedDate')

        if not last_used:
            evaluations.append(build_evaluation(role_id, 'NON_COMPLIANT', event, annotation='This role has never been used or the usage data is not available.'))
            continue

        if last_used < threshold_date:
            evaluations.append(build_evaluation(role_id, 'NON_COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(role_id, 'COMPLIANT', event))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::IAM::Role',
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
