import json
import boto3
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def evaluate_compliance(event, configuration_item, valid_rule_parameters):
    s3_client = boto3.client('s3')
    evaluations = []
    excluded_buckets = valid_rule_parameters.get('ExcludedBuckets', '').split(',')

    buckets = s3_client.list_buckets()['Buckets']
    for bucket in buckets:
        bucket_name = bucket['Name']

        if bucket_name in excluded_buckets:
            evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event, annotation='This bucket is excluded from the check.'))
            continue

        try:
            # Check if versioning is enabled
            versioning = s3_client.get_bucket_versioning(Bucket=bucket_name)
            versioning_status = versioning.get('Status', 'Disabled')
            logger.info(f'Bucket {bucket_name} versioning status: {versioning_status}')

            lifecycle_configuration = s3_client.get_bucket_lifecycle_configuration(Bucket=bucket_name)
            rules = lifecycle_configuration.get('Rules', [])
            compliant = False
            expiration_days = False
            noncurrent_expiration_days = False

            for rule in rules:
                if rule.get('Status') == 'Enabled':
                    logger.info(f'Checking rule: {rule}')

                    # Check Expiration
                    expiration = rule.get('Expiration', {})
                    logger.info(f'Expiration action: {expiration}')
                    if expiration.get('Days', 0) >= 365:
                        expiration_days = True

                    # Check NoncurrentVersionExpiration only if versioning is enabled
                    if versioning_status == 'Enabled':
                        noncurrent_expiration = rule.get('NoncurrentVersionExpiration', {})
                        logger.info(f'NoncurrentVersionExpiration action: {noncurrent_expiration}')
                        if noncurrent_expiration.get('NoncurrentDays', 0) >= 365:
                            noncurrent_expiration_days = True                            

                if versioning_status == 'Enabled':
                    if expiration_days and noncurrent_expiration_days:
                        compliant = True
                        break
                else:
                    if expiration_days:
                        compliant = True
                        break

            if compliant:
                evaluations.append(build_evaluation(bucket_name, 'COMPLIANT', event))
            else:
                evaluations.append(build_evaluation(bucket_name, 'NON_COMPLIANT', event, annotation='No lifecycle rule found with an expiration period of 365 days or more.'))

        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'NoSuchLifecycleConfiguration':
                evaluations.append(build_evaluation(bucket_name, 'NON_COMPLIANT', event, annotation='No lifecycle configuration found.'))
            else:
                logger.error(f"Error processing bucket {bucket_name}: {str(e)}")
                evaluations.append(build_evaluation(bucket_name, 'NOT_APPLICABLE', event, annotation='Error occurred during evaluation.'))

        except Exception as e:
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
