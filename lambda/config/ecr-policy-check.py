import json
import boto3

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    ecr_client = boto3.client('ecr')
    evaluations = []
    excluded_repos = valid_rule_parameters.get('ExcludedRepositories', '').split(',')

    repositories = ecr_client.describe_repositories()['repositories']

    for repo in repositories:
        repo_name = repo['repositoryName']
        repo_arn = repo['repositoryArn']
        if repo_name in excluded_repos:
            evaluations.append(build_evaluation(repo_name, 'COMPLIANT', event, annotation='This repository is excluded from the check.'))
            continue

        policy_text = get_repository_policy(ecr_client, repo_name)
        if policy_text:
            policy = json.loads(policy_text)
            if violates_policy_rules(policy):
                evaluations.append(build_evaluation(repo_name, 'NON_COMPLIANT', event, annotation='Repository policy has Effect set to Allow and Principal set to * or AWS account ID set to *.'))
            else:
                evaluations.append(build_evaluation(repo_name, 'COMPLIANT', event))
        else:
            evaluations.append(build_evaluation(repo_name, 'COMPLIANT', event, annotation='No policy attached to repository.'))

    return evaluations

def get_repository_policy(ecr_client, repository_name):
    try:
        policy = ecr_client.get_repository_policy(repositoryName=repository_name)
        return policy['policyText']
    except ecr_client.exceptions.RepositoryPolicyNotFoundException:
        return None

def violates_policy_rules(policy):
    for statement in policy.get('Statement', []):
        if statement.get('Effect') == 'Allow':
            principal = statement.get('Principal')
            if principal == '*':
                return True
            elif isinstance(principal, dict) and 'AWS' in principal:
                aws_principal = principal['AWS']
                if aws_principal == '*' or (isinstance(aws_principal, list) and '*' in aws_principal):
                    return True
    return False

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::ECR::Repository',
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
