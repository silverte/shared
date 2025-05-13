import json
import boto3
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    s3_client = boto3.client('s3')
    evaluations = []

    # 검사에서 제외할 태그 키와 값 목록을 파라미터로 받음
    exclude_tag_keys = valid_rule_parameters.get('ExcludeTagKeys', '').split(',')
    exclude_tag_values = valid_rule_parameters.get('ExcludeTagValues', '').split(',')

    buckets = s3_client.list_buckets()['Buckets']
    for bucket in buckets:
        bucket_name = bucket['Name']

        # 태그 가져오기
        try:
            bucket_tagging = s3_client.get_bucket_tagging(Bucket=bucket_name)
            tags = {tag['Key']: tag['Value'] for tag in bucket_tagging['TagSet']}
            
            # 태그 중 하나라도 제외 조건에 맞으면 체크 생략
            if any(key.strip() in tags and tags[key.strip()].lower() in exclude_tag_values for key in exclude_tag_keys):
                evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event, annotation='This bucket is excluded from the check due to tags.'))
                continue
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchTagSet':
                # 태그가 없는 경우는 그냥 넘어가도록 함
                pass
            else:
                logger.error(f"Error processing bucket {bucket_name}: {str(e)}")
                evaluations.append(build_evaluation(bucket_name, 'NOT_APPLICABLE', event, annotation=f"Error occurred during evaluation: {str(e)}"))
                continue

        # 로깅 설정 확인
        try:
            bucket_logging = s3_client.get_bucket_logging(Bucket=bucket_name)
            if 'LoggingEnabled' in bucket_logging:
                evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event))
            else:
                evaluations.append(build_evaluation(bucket_name, 'NON_COMPLIANT', event, annotation='Logging is not enabled for this bucket.'))

        except ClientError as e:
            error_code = e.response['Error']['Code']
            logger.error(f"Error processing bucket {bucket_name}: {str(e)}")
            evaluations.append(build_evaluation(bucket_name, 'NOT_APPLICABLE', event, annotation=f"Error occurred during evaluation: {error_code}"))

    return evaluations

def build_evaluation(resource_id, compliance_type, event, annotation=None):
    evaluation = {
        'ComplianceResourceType': 'AWS::S3::Bucket',
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

    # 'configurationItem'이 존재하는지 확인하고, 없을 경우 기본값 사용
    if 'configurationItem' in invoking_event:
        configuration_item = invoking_event['configurationItem']
    else:
        # 'configurationItem'이 없는 경우 빈 객체로 설정하거나 다른 로직 사용
        configuration_item = None

    evaluations = evaluate_compliance(event, configuration_item, rule_parameters)

    config_client = boto3.client('config')
    result_token = event['resultToken']
    test_mode = result_token == 'TESTMODE'

    config_client.put_evaluations(
        Evaluations=evaluations,
        ResultToken=result_token,
        TestMode=test_mode
    )
