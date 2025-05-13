import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    iam_client = boto3.client('iam')
    evaluations = []
    excluded_users = valid_rule_parameters.get('ExcludedUsers', '').split(',')

    users = iam_client.list_users()['Users']
    for user in users:
        user_name = user['UserName']
        user_id = user['UserId']
        if user_name in excluded_users:
            evaluations.append(build_evaluation(user_id, 'COMPLIANT', event, annotation='This user is excluded from the check.'))
            continue

        access_keys = iam_client.list_access_keys(UserName=user_name)['AccessKeyMetadata']
        if len(access_keys) > 1:
            evaluations.append(build_evaluation(user_id, 'NON_COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(user_id, 'COMPLIANT', event))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::IAM::User',
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
