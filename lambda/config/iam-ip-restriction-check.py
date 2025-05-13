import json
import boto3
import ipaddress

# 기본 설정
DEFAULT_MAX_IP_NUMS = 20
DEFAULT_RESOURCE_TYPE = 'AWS::IAM::User'

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    iam_client = boto3.client('iam')
    evaluations = []

    users_list = get_all_users(iam_client)
    whitelisted_user_names = valid_rule_parameters.get('WhitelistedUserNames', [])
    max_ip_nums = valid_rule_parameters.get('maxIpNums', DEFAULT_MAX_IP_NUMS)  
    
    if not users_list:
        return None

    for user in users_list:
        if user['UserName'] in whitelisted_user_names:
            evaluations.append(build_evaluation(user['UserId'], 'COMPLIANT', event, annotation=f"This user {user['UserName']} is whitelisted."))
            continue
            
        if not allows_console_login(iam_client, user['UserName']):
            evaluations.append(build_evaluation(user['UserId'], 'NOT_APPLICABLE', event, annotation=f"This user {user['UserName']} is not a console user."))
            continue

        evaluater = ComplianceEvaluator(iam_client, user['UserName'], max_ip_nums)
        compliance_type = evaluater.check_compliant()
        annotation = evaluater.annotation

        if compliance_type == 'NON_COMPLIANT' and annotation is None:
            annotation = f"This user {user['UserName']} is not IP restricted."

        evaluations.append(build_evaluation(user['UserId'], compliance_type, event, annotation=annotation))

    return evaluations

def get_all_users(client):
    users = []
    paginator = client.get_paginator('list_users')
    for response in paginator.paginate():
        users.extend(response['Users'])
    return users

def allows_console_login(client, user_name):
    try:
        client.get_login_profile(UserName=user_name)
        return True
    except client.exceptions.NoSuchEntityException:
        return False
        
def evaluate_parameters(rule_parameters):
    valid_rule_parameters = {}

    valid_rule_parameters['WhitelistedUserNames'] = []
    if 'WhitelistedUserNames' in rule_parameters:
        whitelisted_user_names = rule_parameters['WhitelistedUserNames'].replace(' ', '').split(',')
        valid_whitelist = []
        for whitelisted_user_name in whitelisted_user_names:
            if len(whitelisted_user_name) > 64:
                raise ValueError('WhitelistedUserNames must be less than 64 characters.')
            valid_whitelist.append(whitelisted_user_name)
        valid_rule_parameters['WhitelistedUserNames'] = valid_whitelist

    max_ip_nums = DEFAULT_MAX_IP_NUMS
    if 'maxIpNums' in rule_parameters:
        max_ip_nums = int(rule_parameters['maxIpNums'])
        if max_ip_nums < 1:
            raise ValueError('maxIpNums must be greater than 1.')
        if max_ip_nums > 2**32-1:
            raise ValueError('maxIpNums must be less than 2**32-1.')
    valid_rule_parameters['maxIpNums'] = max_ip_nums

    return valid_rule_parameters

class ComplianceEvaluator:
    def __init__(self, iam_client, user_name, max_ip_num):
        self.iam_client = iam_client
        self.user_name = user_name
        self.max_ip_num = max_ip_num
        self.is_ip_denied = False
        self.is_all_policy_ip_allowed = None
        self.annotation = None

    def check_compliant(self):
        compliance_type = 'NON_COMPLIANT'

        self.check_inline_policy()
        self.check_attached_policy()

        user_groups = self.iam_client.list_groups_for_user(UserName=self.user_name)
        for group in user_groups['Groups']:
            group_name = group['GroupName']
            self.check_group_inline_policy(group_name)
            self.check_group_attached_policy(group_name)

        if self.is_ip_denied is True or self.is_all_policy_ip_allowed is True:
            compliance_type = 'COMPLIANT'

        return compliance_type

    def check_inline_policy(self):
        if self.is_ip_denied is True:
            return

        inline_policies = self.iam_client.list_user_policies(UserName=self.user_name)
        for inline_policy_name in inline_policies['PolicyNames']:
            inline_policy = self.iam_client.get_user_policy(UserName=self.user_name, PolicyName=inline_policy_name)
            statements = inline_policy['PolicyDocument']['Statement']
            self.check_ip_restricted_condition(statements)

    def check_attached_policy(self):
        if self.is_ip_denied is True:
            return

        attached_policies = self.iam_client.list_attached_user_policies(UserName=self.user_name)
        for attached_policy in attached_policies['AttachedPolicies']:
            policy_document = self.get_policy_document(attached_policy['PolicyArn'])
            statements = policy_document['Statement']
            self.check_ip_restricted_condition(statements)

    def check_group_inline_policy(self, group_name):
        if self.is_ip_denied is True:
            return

        group_inline_policies = self.iam_client.list_group_policies(GroupName=group_name)
        for group_inline_policy_name in group_inline_policies['PolicyNames']:
            group_inline_policy = self.iam_client.get_group_policy(GroupName=group_name, PolicyName=group_inline_policy_name)
            statements = group_inline_policy['PolicyDocument']['Statement']
            self.check_ip_restricted_condition(statements)

    def check_group_attached_policy(self, group_name):
        if self.is_ip_denied is True:
            return

        group_attached_policies = self.iam_client.list_attached_group_policies(GroupName=group_name)
        for group_attached_policy in group_attached_policies['AttachedPolicies']:
            policy_document = self.get_policy_document(group_attached_policy['PolicyArn'])
            statements = policy_document['Statement']
            self.check_ip_restricted_condition(statements)

    def get_policy_document(self, policy_arn):
        policy = self.iam_client.get_policy(PolicyArn=policy_arn)
        policy_version_id = policy['Policy']['DefaultVersionId']
        policy_version = self.iam_client.get_policy_version(PolicyArn=policy_arn, VersionId=policy_version_id)
        return policy_version['PolicyVersion']['Document']

    def check_ip_restricted_condition(self, policy_statements):
        if isinstance(policy_statements, dict):
            policy_statements = [policy_statements]

        for statement in policy_statements:
            if self.is_ip_deny_condition_satisfied(statement):
                self.is_ip_denied = True
                break
            if self.is_ip_allow_condition_satisfied(statement):
                if self.is_all_policy_ip_allowed is not False:
                    self.is_all_policy_ip_allowed = True
            else:
                self.is_all_policy_ip_allowed = False

    def is_ip_deny_condition_satisfied(self, statement):
        try:
            allow_ips = []
            condition = statement['Condition']
            if statement['Effect'] == 'Deny':
                if 'NotIpAddress' in condition.keys():
                    allow_ips = condition['NotIpAddress']['aws:SourceIp']
                elif 'ForAnyValue:NotIpAddress' in condition.keys():
                    allow_ips = condition['ForAnyValue:NotIpAddress']['aws:SourceIp']
        except KeyError:
            pass

        return self.is_valid_ips(allow_ips)

    def is_ip_allow_condition_satisfied(self, statement):
        try:
            allow_ips = []
            condition = statement['Condition']
            if statement['Effect'] == 'Allow':
                if 'IpAddress' in condition.keys():
                    allow_ips = condition['IpAddress']['aws:SourceIp']
                elif 'ForAnyValue:IpAddress' in condition.keys():
                    allow_ips = condition['ForAnyValue:IpAddress']['aws:SourceIp']
        except KeyError:
            pass

        return self.is_valid_ips(allow_ips)

    def is_valid_ips(self, ips):
        if not ips:
            is_valid = False
        elif self.is_over_maximum_ip_nums(ips):
            is_valid = False
        else:
            is_valid = True

        return is_valid

    def is_over_maximum_ip_nums(self, ips):
        is_over = False
        unique_ips = list(set(ips))

        ip_nums = sum(ipaddress.ip_network(ip).num_addresses for ip in unique_ips)
        if ip_nums > self.max_ip_num:
            self.annotation = f'IAM Policy includes more than maximum ip addresses: {ip_nums}'
            is_over = True

        return is_over

def build_evaluation(resource_id, compliance_type, event, resource_type=DEFAULT_RESOURCE_TYPE, annotation=None):
    eval_cc = {}
    if annotation:
        eval_cc['Annotation'] = annotation
    eval_cc['ComplianceResourceType'] = resource_type
    eval_cc['ComplianceResourceId'] = resource_id
    eval_cc['ComplianceType'] = compliance_type
    eval_cc['OrderingTimestamp'] = str(json.loads(event['invokingEvent'])['notificationCreationTime'])
    return eval_cc

def lambda_handler(event, context):
    invoking_event = json.loads(event['invokingEvent'])
    rule_parameters = {}
    if 'ruleParameters' in event:
        rule_parameters = json.loads(event['ruleParameters'])

    valid_rule_parameters = evaluate_parameters(rule_parameters)

    configuration_item = invoking_event['configurationItem']
    if configuration_item['resourceType'] != DEFAULT_RESOURCE_TYPE:
        return build_evaluation(event['accountId'], 'NOT_APPLICABLE', event)

    compliance_result = evaluate_compliance(event, configuration_item, valid_rule_parameters)
    evaluations = []

    if isinstance(compliance_result, list):
        evaluations = compliance_result
    else:
        evaluations.append(build_evaluation(configuration_item['resourceId'], compliance_result, event))

    AWS_CONFIG_CLIENT = boto3.client('config')
    result_token = event['resultToken']
    test_mode = result_token == 'TESTMODE'

    while evaluations:
        AWS_CONFIG_CLIENT.put_evaluations(Evaluations=evaluations[:100], ResultToken=result_token, TestMode=test_mode)
        evaluations = evaluations[100:]

    return evaluations
