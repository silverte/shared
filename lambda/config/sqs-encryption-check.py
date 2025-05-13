import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    sqs_client = boto3.client('sqs')
    evaluations = []
    excluded_queues = valid_rule_parameters.get('ExcludedQueues', '').split(',')

    queues = sqs_client.list_queues().get('QueueUrls', [])
    for queue_url in queues:
        if queue_url in excluded_queues:
            evaluations.append(build_evaluation(queue_url, 'COMPLIANT', event, annotation='This queue is excluded from the check.'))
            continue

        attributes = sqs_client.get_queue_attributes(QueueUrl=queue_url, AttributeNames=['KmsMasterKeyId','SqsManagedSseEnabled']).get('Attributes', {})
        kms_key_id = attributes.get('KmsMasterKeyId')
        managed_sse_enabled = attributes.get('SqsManagedSseEnabled')
        if kms_key_id or (managed_sse_enabled == 'true'):
            evaluations.append(build_evaluation(queue_url, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(queue_url, 'NON_COMPLIANT', event))

    return evaluations

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
