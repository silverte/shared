import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    iam_client = boto3.client('iam')
    evaluations = []
    
    # Directly split the ExcludedGroups parameter into a list.
    excluded_groups = valid_rule_parameters.get('ExcludedGroups', '').split(',')

    # Retrieve all IAM groups.
    groups = iam_client.list_groups()['Groups']
    for group in groups:
        group_name = group['GroupName'].strip()

        # Skip groups that are in the excluded list.
        if group_name in excluded_groups:
            continue

        # Check the policies attached to the group.
        attached_policies = iam_client.list_attached_group_policies(GroupName=group_name)['AttachedPolicies']
        for policy in attached_policies:
            # If the group has the AdministratorAccess policy attached.
            if policy['PolicyName'] == 'AdministratorAccess':
                # Retrieve the users in the group.
                users = iam_client.get_group(GroupName=group_name)['Users']
                # Check if the number of users exceeds 5.
                if len(users) > 5:
                    evaluations.append(build_evaluation(group['GroupId'], 'NON_COMPLIANT', event))
                else:
                    evaluations.append(build_evaluation(group['GroupId'], 'COMPLIANT', event))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    # Create a compliance evaluation result.
    evaluation = {
        'ComplianceResourceType': 'AWS::IAM::Group',
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
    configuration_item = invoking_event['configurationItem']
    evaluations = evaluate_compliance(event, configuration_item, rule_parameters)

    config_client = boto3.client('config')
    result_token = event['resultToken']
    test_mode = result_token == 'TESTMODE'
    
    # Send the evaluation results to AWS Config.
    config_client.put_evaluations(
        Evaluations=evaluations,
        ResultToken=result_token,
        TestMode=test_mode
    )
