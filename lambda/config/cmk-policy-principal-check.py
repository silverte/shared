import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    kms_client = boto3.client('kms')
    evaluations = []
    excluded_keys = valid_rule_parameters.get('ExcludedKeys', '').split(',')

    keys = kms_client.list_keys()['Keys']
    for key in keys:
        key_id = key['KeyId']
        key_metadata = kms_client.describe_key(KeyId=key_id)['KeyMetadata']
        key_arn = key_metadata['Arn']
        
        if key_arn in excluded_keys:
            evaluations.append(build_evaluation(key_id, 'COMPLIANT', event, annotation='This key is excluded from the check.'))
            continue

        policy = kms_client.get_key_policy(KeyId=key_id, PolicyName='default')['Policy']
        policy = json.loads(policy)
        if violates_policy_rules(policy):
            evaluations.append(build_evaluation(key_id, 'NON_COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(key_id, 'COMPLIANT', event))

    return evaluations

def violates_policy_rules(policy):
    for statement in policy.get('Statement', []):
        if principal_is_wildcard(statement.get('Principal')) and not statement.get('Condition'):
            return True
    return False

def principal_is_wildcard(principal):
    if principal == '*':
        return True
    elif isinstance(principal, dict) and 'AWS' in principal:
        aws_principal = principal['AWS']
        if aws_principal == '*' or (isinstance(aws_principal, list) and '*' in aws_principal):
            return True
    return False

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::KMS::Key',
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
