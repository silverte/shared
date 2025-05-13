import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    elbv2_client = boto3.client('elbv2')
    evaluations = []
    excluded_nlbs = valid_rule_parameters.get('ExcludedNLBs', '').split(',')

    load_balancers = elbv2_client.describe_load_balancers()['LoadBalancers']
    
    for lb in load_balancers:
        lb_arn = lb['LoadBalancerArn']
        if lb_arn in excluded_nlbs:
            evaluations.append(build_evaluation(lb_arn, 'COMPLIANT', event, annotation='This NLB is excluded from the check.'))
            continue

        if lb['Type'] == 'network':
            listeners = elbv2_client.describe_listeners(LoadBalancerArn=lb_arn)['Listeners']
            for listener in listeners:
                if listener['Protocol'] == 'TLS':
                    if listener.get('SslPolicy') == 'ELBSecurityPolicy-TLS13-1-2-2021-06':
                        evaluations.append(build_evaluation(lb_arn, 'COMPLIANT', event))
                    else:
                        evaluations.append(build_evaluation(lb_arn, 'NON_COMPLIANT', event))
                        break
            else:
                evaluations.append(build_evaluation(lb_arn, 'COMPLIANT', event, annotation='No TLS listeners found.'))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::ElasticLoadBalancingV2::LoadBalancer',
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
