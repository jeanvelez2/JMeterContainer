#!/bin/sh
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"
export DATE_NOW=`date '+%F_%H:%M:%S'`

# AWS Configuration
export BUCKET_NAME=<Replace with S3 Bucket Name>

# AWS Configuration (Local Machine)
# export AWS_ACCESS_KEY_ID=<Replace with AWS Access Key>
# export AWS_SECRET_ACCESS_KEY=<Replace with AWS Secret Access Key>
# export DEFAULT_REGION=<Replace with Desired region>

# Location for JMeter Logs and Results (Local or S3 path)
export LOG_PATH=s3://$BUCKET_NAME/logs/
export RESULT_PATH=s3://$BUCKET_NAME/results/

# JMeter Script
export TEST_JMX=JMeter_TEST.jmx
export TEST_JMX_PATH=s3://$BUCKET_NAME/$TEST_JMX

# JMeter Logs
export TEST_LOG=test_console_$DATE_NOW.log
export TEST_LOG_DIR=/test/$TEST_LOG

# JMeter Test results
export TEST_RESULT=test_results_$DATE_NOW.xml
export TEST_RESULT_DIR=/test/$TEST_RESULT

# Configure AWS Credentials (Only useful for local environments)
# aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
# aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
# aws configure set region $DEFAULT_REGION

# Download JMX file from S3
aws s3 cp $TEST_JMX_PATH .

# Generate blank Log and test result file
touch $TEST_LOG_DIR
touch $TEST_RESULT_DIR

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Launch JMeter Script
jmeter -n -t $TEST_JMX -l $TEST_RESULT -j $TEST_LOG -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice .samplerData=true -JnumberOfThreads=20 -JloopCount=50

echo "END Running Jmeter on `date`"

# Upload Log and Test results to S3 Bucket
echo "Uploading test logs: ${TEST_LOG_DIR} into S3: ${LOG_PATH}"
aws s3 cp $TEST_LOG_DIR $LOG_PATH

echo "Uploading test results: ${TEST_RESULT_DIR} into S3: ${RESULT_PATH}"
aws s3 cp $TEST_RESULT_DIR $RESULT_PATH

# Remove Log and Test results to S3 Bucket from Container
echo "File upload to S3: Completed."
rm -rf $TEST_LOG
rm -rf $TEST_RESULT_DIR
echo "Files removed locally."