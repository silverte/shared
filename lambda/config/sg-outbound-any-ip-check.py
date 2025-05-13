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
        
        compliant = True
        for rule in sg.get('IpPermissionsEgress', []):
            for ip_range in rule.get('IpRanges', []):
                if ip_range['CidrIp'] == '0.0.0.0/0':
                    if 'FromPort' in rule and 'ToPort' in rule:
                        from_port = rule['FromPort']
                        to_port = rule['ToPort']
                        if not (from_port == 80 and to_port == 80) and not (from_port == 443 and to_port == 443):
                            compliant = False
                            break
                    else:
                        compliant = False
                        break
            if not compliant:
                break

        if compliant:
            evaluations.append(build_evaluation(sg_id, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(sg_id, 'NON_COMPLIANT', event))

    return evaluations

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
