import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    elbv2_client = boto3.client('elbv2')
    ec2_client = boto3.client('ec2')
    evaluations = []
    excluded_albs = valid_rule_parameters.get('ExcludedALBs', '').split(',')

    load_balancers = elbv2_client.describe_load_balancers()['LoadBalancers']

    for lb in load_balancers:
        lb_arn = lb['LoadBalancerArn']
        if lb_arn in excluded_albs:
            evaluations.append(build_evaluation(lb_arn, 'COMPLIANT', event, annotation='This ALB is excluded from the check.'))
            continue

        if lb['Type'] == 'application':
            sg_ids = lb['SecurityGroups']
            for sg_id in sg_ids:
                sg_details = ec2_client.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
                inbound_rules = sg_details.get('IpPermissions')
                outbound_rules = sg_details.get('IpPermissionsEgress')

                if not inbound_rules or not outbound_rules:
                    evaluations.append(build_evaluation(lb_arn, 'NON_COMPLIANT', event, annotation=f'Security group {sg_id} has no inbound or outbound rules.'))
                    break
            else:
                evaluations.append(build_evaluation(lb_arn, 'COMPLIANT', event))

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
