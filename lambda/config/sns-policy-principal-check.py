import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    sns_client = boto3.client('sns')
    evaluations = []
    excluded_topics = valid_rule_parameters.get('ExcludedTopics', '').split(',')

    topics = sns_client.list_topics().get('Topics', [])

    for topic in topics:
        topic_arn = topic['TopicArn']
        if topic_arn in excluded_topics:
            evaluations.append(build_evaluation(topic_arn, 'COMPLIANT', event, annotation='This topic is excluded from the check.'))
            continue

        attributes = sns_client.get_topic_attributes(TopicArn=topic_arn)['Attributes']
        policy = attributes.get('Policy')
        if policy:
            policy = json.loads(policy)
            if violates_policy_rules(policy):
                evaluations.append(build_evaluation(topic_arn, 'NON_COMPLIANT', event))
            else:
                evaluations.append(build_evaluation(topic_arn, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(topic_arn, 'COMPLIANT', event))

    return evaluations

def violates_policy_rules(policy):
    for statement in policy.get('Statement', []):
        if (statement.get('Effect') == 'Allow' and
            not statement.get('Condition') and
            principal_is_wildcard(statement.get('Principal'))):
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
        'ComplianceResourceType': 'AWS::SNS::Topic',
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
