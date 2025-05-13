import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    ec2_client = boto3.client('ec2')
    evaluations = []
    excluded_sgs = valid_rule_parameters.get('ExcludedSecurityGroups', '').split(',')

    security_groups = ec2_client.describe_security_groups()['SecurityGroups']
    
    for sg in security_groups:
        sg_id = sg['GroupId']
        if sg_id in excluded_sgs:
            evaluations.append(build_evaluation(sg_id, 'COMPLIANT', event, annotation='This security group is excluded from the check.'))
            continue

        if allows_all_traffic(sg):
            evaluations.append(build_evaluation(sg_id, 'NON_COMPLIANT', event, annotation='Security group allows all inbound traffic.'))
        else:
            evaluations.append(build_evaluation(sg_id, 'COMPLIANT', event))

    return evaluations

def allows_all_traffic(sg):
    for permission in sg.get('IpPermissions', []):
        if permission.get('IpProtocol') == '-1':
            return True
        if permission.get('FromPort') == 0 and permission.get('ToPort') == 65535:
            for ip_range in permission.get('IpRanges', []):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    return True
            for ipv6_range in permission.get('Ipv6Ranges', []):
                if ipv6_range.get('CidrIpv6') == '::/0':
                    return True
    return False

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::EC2::SecurityGroup',
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
