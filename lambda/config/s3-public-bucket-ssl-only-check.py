import json
import boto3
import logging
from botocore.exceptions import ClientError

# 로그 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    s3_client = boto3.client('s3')
    evaluations = []
    excluded_buckets = valid_rule_parameters.get('ExcludedBuckets', '').split(',')

    # List all buckets
    buckets = s3_client.list_buckets()['Buckets']

    for bucket in buckets:
        bucket_name = bucket['Name']

        # Skip excluded buckets
        if bucket_name in excluded_buckets:
            evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event, annotation='This bucket is excluded from the check.'))
            continue

        try:
            # Attempt to get the bucket policy
            result = s3_client.get_bucket_policy(Bucket=bucket_name)
            bucket_policy = json.loads(result['Policy'])

            is_public = False
            enforces_ssl = False

            for statement in bucket_policy.get('Statement', []):
                if statement.get('Effect') == 'Allow':
                    principal = statement.get('Principal')
                    if principal == "*" or ('AWS' in principal and principal['AWS'] == "*"):
                        is_public = True
                if statement.get('Effect') == 'Deny':
                    conditions = statement.get('Condition', {})
                    if 'Bool' in conditions and conditions['Bool'].get('aws:SecureTransport') == 'false':
                        enforces_ssl = True

            if is_public and not enforces_ssl:
                evaluations.append(build_evaluation(bucket_name, 'NON_COMPLIANT', event, annotation='The bucket allows public access without enforcing SSL.'))
            else:
                evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event))

        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'NoSuchBucketPolicy':
                # If no policy is found, consider it compliant
                evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event, annotation='The bucket has no policy.'))
            else:
                # Log the error and mark as NOT_APPLICABLE
                logger.error(f"Error processing bucket {bucket_name}: {str(e)}")
                evaluations.append(build_evaluation(bucket_name, 'NOT_APPLICABLE', event, annotation='Error occurred during evaluation.'))

        except Exception as e:
            # Log the error and mark as NOT_APPLICABLE
            logger.error(f"Error processing bucket {bucket_name}: {str(e)}")
            evaluations.append(build_evaluation(bucket_name, 'NOT_APPLICABLE', event, annotation='Error occurred during evaluation.'))

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
    configuration_item = invoking_event.get('configurationItem')
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
