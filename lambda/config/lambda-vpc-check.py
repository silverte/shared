import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    lambda_client = boto3.client('lambda')
    evaluations = []

    # 예외 처리 태그 키와 값
    exclude_tag_keys = valid_rule_parameters.get('ExcludeTagKeys', '').split(',')
    exclude_tag_values = valid_rule_parameters.get('ExcludeTagValues', '').split(',')

    # 모든 Lambda 함수 목록 가져오기
    functions = lambda_client.list_functions()['Functions']
    for function in functions:
        function_name = function['FunctionName']
        function_arn = function['FunctionArn']

        try:
            # 함수의 태그 가져오기
            tags = lambda_client.list_tags(Resource=function_arn).get('Tags', {})

            # 특정 태그 중 하나라도 설정된 경우 검사에서 제외
            if any(key.strip() in tags and tags[key.strip()].lower() in exclude_tag_values for key in exclude_tag_keys):                
                evaluations.append(build_evaluation(function_name, 'COMPLIANT', event, annotation='This function is excluded from the check due to specific tags.'))
                continue

            # 함수의 VpcConfig 정보 가져오기
            function_details = lambda_client.get_function_configuration(FunctionName=function_name)
            vpc_config = function_details.get('VpcConfig', None)

            if vpc_config and vpc_config.get('VpcId'):
                # VpcConfig가 존재하고 VpcId가 있는 경우, 함수는 VPC에 있음
                evaluations.append(build_evaluation(function_name, 'COMPLIANT', event))
            else:
                # VpcConfig가 없거나 VpcId가 없는 경우, 함수는 VPC에 없음
                evaluations.append(build_evaluation(function_name, 'NON_COMPLIANT', event, annotation='Function is not in a VPC.'))

        except Exception as e:
            # 오류를 기록하고 NOT_APPLICABLE로 표시
            logger.error(f"Error processing function {function_name}: {str(e)}")
            evaluations.append(build_evaluation(function_name, 'NOT_APPLICABLE', event, annotation='Error occurred during evaluation.'))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::Lambda::Function',
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
    if 'configurationItem' in invoking_event:
        configuration_item = invoking_event['configurationItem']
    else:
        configuration_item = None
    evaluations = evaluate_compliance(event, configuration_item, rule_parameters)

    config_client = boto3.client('config')
    result_token = event['resultToken']
    test_mode = result_token == 'TESTMODE'
    
    if evaluations:
        config_client.put_evaluations(
            Evaluations=evaluations,
            ResultToken=result_token,
            TestMode=test_mode
        )