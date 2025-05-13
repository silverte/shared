import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    sqs_client = boto3.client('sqs')
    evaluations = []
    queues = sqs_client.list_queues().get('QueueUrls', [])

    for queue_url in queues:
        attributes = sqs_client.get_queue_attributes(QueueUrl=queue_url, AttributeNames=['Policy']).get('Attributes', {})
        policy = attributes.get('Policy')
        if policy:
            policy = json.loads(policy)
            if violates_policy_rules(policy):
                evaluations.append(build_evaluation(queue_url, 'NON_COMPLIANT', event))
            else:
                evaluations.append(build_evaluation(queue_url, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(queue_url, 'COMPLIANT', event))

    return evaluations

def violates_policy_rules(policy):
    for statement in policy.get('Statement', []):
        if (statement.get('Effect') == 'Allow' and
            not statement.get('Condition') and
            action_starts_with_sqs(statement.get('Action'))):
            principal = statement.get('Principal', {})
            if (principal == '*' or
                (isinstance(principal, dict) and
                 'AWS' in principal and
                 (principal['AWS'] == '*' or
                  (isinstance(principal['AWS'], list) and '*' in principal['AWS'])))):
                return True
    return False

def action_starts_with_sqs(action):
    if isinstance(action, str):
        return action.lower().startswith('sqs:')
    elif isinstance(action, list):
        return any(act.lower().startswith('sqs:') for act in action)
    return False

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::SQS::Queue',
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
