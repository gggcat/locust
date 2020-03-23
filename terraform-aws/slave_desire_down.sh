#!/bin/bash

#
# locust 1800users/1hatchでリニアにスケールする
#

CLUSTER_NAME=locust-fargate-default
SERVICE_NAME=locust-slave
DESIRED_COUNT=0

aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-count ${DESIRED_COUNT}
TASKS=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-status 'RUNNING' --output text --query 'taskARNS[*]')

for task in ${TASKS} ; do
    aws ecs stop-task --cluster ${CLUSTER_NAME} --task $task --reason "force stopped"
done
