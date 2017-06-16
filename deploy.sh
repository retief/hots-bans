# deploy.sh
#! /bin/bash

SHA1=$1

# Push image to ECR
$(aws ecr get-login --region us-east-1)
docker push 443955892116.dkr.ecr.us-east-1.amazonaws.com/hots-dockers:$SHA1

# Create new Elastic Beanstalk version
EB_BUCKET=hots-bans-deploy-bucket
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE --region us-east-1
aws elasticbeanstalk create-application-version --application-name hots-bans \
    --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE \
    --region us-east-1

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name hots-bans-env \
    --version-label $SHA1 \
    --region us-east-1
