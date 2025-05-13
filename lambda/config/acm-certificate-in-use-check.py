import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    acm_client = boto3.client('acm')
    evaluations = []
    excluded_certificates = valid_rule_parameters.get('ExcludedCertificates', '').split(',')

    certificates = acm_client.list_certificates(CertificateStatuses=['ISSUED'])['CertificateSummaryList']
    
    for cert in certificates:
        cert_arn = cert['CertificateArn']
        if cert_arn in excluded_certificates:
            evaluations.append(build_evaluation(cert_arn, 'COMPLIANT', event, annotation='This certificate is excluded from the check.'))
            continue

        cert_details = acm_client.describe_certificate(CertificateArn=cert_arn)['Certificate']
        in_use = check_certificate_usage(cert_details)

        if in_use:
            evaluations.append(build_evaluation(cert_arn, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(cert_arn, 'NON_COMPLIANT', event))

    return evaluations

def check_certificate_usage(cert_details):
    in_use_by_elb = any(cert_details.get('InUseBy', []))
    return in_use_by_elb

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::ACM::Certificate',
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
