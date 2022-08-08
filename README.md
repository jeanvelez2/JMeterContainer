# Instructions
1. Create AWS S3 Bucket (Public for Local tests).
2. Create 2 folder in S3 Bucket (logs and results).
3. Access JMeter_TEST.jmx and entrypoint.sh on your local machine and modify the values presented.
4. Upload JMeter_TEST.jmx and entrypoint.sh files in the AWS S3 Bucket.
5. Start Docker on your local machine.
6. Setup AWS CLI profile.
a. Reference: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
7. Execute the commands from the following sections:
a. Build Image
b. Run Container
8. View Results and Logs in AWS S3 Bucket.

# Sections:

### Build Image
- docker build -t jmeter-loadtesting:latest .

### Run container 
- docker container run -it jmeter-loadtesting:latest

### Run container without entrypoint (Troubleshooting)
- docker run -it --rm --entrypoint sh jmeter-loadtesting:latest