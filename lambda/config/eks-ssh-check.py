import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    eks_client = boto3.client('eks')
    evaluations = []
    excluded_clusters = valid_rule_parameters.get('ExcludedClusters', '').split(',')

    clusters = eks_client.list_clusters()['clusters']
    
    for cluster_name in clusters:
        if cluster_name in excluded_clusters:
            continue

        nodegroups = eks_client.list_nodegroups(clusterName=cluster_name)['nodegroups']
        for nodegroup_name in nodegroups:
            nodegroup = eks_client.describe_nodegroup(clusterName=cluster_name, nodegroupName=nodegroup_name)['nodegroup']
            remote_access_config = nodegroup.get('remoteAccess', {})
            ssh_access_enabled = remote_access_config.get('ec2SshKey', None) is not None

            if ssh_access_enabled:
                evaluations.append(build_evaluation(cluster_name, 'NON_COMPLIANT', event, annotation=f'Nodegroup {nodegroup_name} has SSH access enabled.'))
            else:
                evaluations.append(build_evaluation(cluster_name, 'COMPLIANT', event))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::EKS::Cluster',
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
