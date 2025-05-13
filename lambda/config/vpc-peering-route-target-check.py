import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    ec2_client = boto3.client('ec2')
    evaluations = []
    excluded_peerings = valid_rule_parameters.get('ExcludedPeerings', '').split(',')

    peering_connections = ec2_client.describe_vpc_peering_connections()['VpcPeeringConnections']
    
    for peering in peering_connections:
        peering_id = peering['VpcPeeringConnectionId']
        if peering_id in excluded_peerings:
            evaluations.append(build_evaluation(peering_id, 'COMPLIANT', event, annotation='This peering connection is excluded from the check.'))
            continue

        accepter_vpc_id = peering.get('AccepterVpcInfo', {}).get('VpcId')
        requester_vpc_id = peering.get('RequesterVpcInfo', {}).get('VpcId')

        if check_route_tables_for_any_ip(ec2_client, accepter_vpc_id) or check_route_tables_for_any_ip(ec2_client, requester_vpc_id):
            evaluations.append(build_evaluation(peering_id, 'NON_COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(peering_id, 'COMPLIANT', event))

    return evaluations

def check_route_tables_for_any_ip(ec2_client, vpc_id):
    if not vpc_id:
        return False
    route_tables = ec2_client.describe_route_tables(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])['RouteTables']
    for route_table in route_tables:
        for route in route_table.get('Routes', []):
            if route.get('DestinationCidrBlock') == '0.0.0.0/0' and 'VpcPeeringConnectionId' in route:
                return True
    return False

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::EC2::VPCPeeringConnection',
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
