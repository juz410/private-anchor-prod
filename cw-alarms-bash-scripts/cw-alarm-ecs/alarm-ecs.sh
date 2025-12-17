#!/usr/bin/env bash
set -euo pipefail

########################################
# Config – EDIT THESE
########################################

# 1) Positional args (with defaults)
CLUSTER_NAME="${1:-anchor-prod}"                 # ECS cluster name
RESOURCE_PREFIX="${2:-anchor-prod}"             # your resource_name_prefix
AWS_REGION="${3:-ap-southeast-5}"
AWS_PROFILE="${4:-anchor-prod}"

# 2) SNS topic ARNs – get from Terraform output and paste here
SNS_TOPIC_RUNNING_ARN="arn:aws:sns:ap-southeast-5:328425459315:gap-runningtaskcount-topic"
SNS_TOPIC_PENDING_ARN="arn:aws:sns:ap-southeast-5:328425459315:gap-pendingtaskcount-topic"
SNS_TOPIC_CPU_ARN="arn:aws:sns:ap-southeast-5:328425459315:gap-servicecpuutilization-topic"
SNS_TOPIC_MEM_ARN="arn:aws:sns:ap-southeast-5:328425459315:gap-servicememoryutilization-topic"

# 3) Thresholds / timings
CPU_THRESHOLDS=(80 90)       # %
MEM_THRESHOLDS=(80 90)       # %
PENDING_TASK_THRESHOLD=10     # ≥ this many pending tasks
PERIOD_SECONDS=300           # 5 minutes, matches your spreadsheet
EVALUATION_PERIODS=1
TREAT_MISSING="missing"      # same as your Terraform alarms

########################################
# Checks
########################################

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required (sudo yum/apt/brew install jq)"; exit 1
fi

echo "Cluster        : ${CLUSTER_NAME}"
echo "Prefix         : ${RESOURCE_PREFIX}"
echo "Region         : ${AWS_REGION}"
echo "Profile        : ${AWS_PROFILE}"
echo "CPU thresholds : ${CPU_THRESHOLDS[*]} %"
echo "MEM thresholds : ${MEM_THRESHOLDS[*]} %"
echo

########################################
# Helper: create alarm
########################################
create_alarm() {
  local alarm_name="$1"
  local description="$2"
  local namespace="$3"
  local metric_name="$4"
  local statistic="$5"
  local comparison="$6"
  local threshold="$7"
  local sns_arn="$8"
  local unit="$9"
  shift 9
  local dimensions=("$@")    # as "Name=...,Value=..." pairs

  echo "  - put-metric-alarm: ${alarm_name}"

  aws cloudwatch put-metric-alarm \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" \
    --alarm-name "${alarm_name}" \
    --alarm-description "${description}" \
    --namespace "${namespace}" \
    --metric-name "${metric_name}" \
    --statistic "${statistic}" \
    --period "${PERIOD_SECONDS}" \
    --evaluation-periods "${EVALUATION_PERIODS}" \
    --threshold "${threshold}" \
    --comparison-operator "${comparison}" \
    --treat-missing-data "${TREAT_MISSING}" \
    --unit "${unit}" \
    --alarm-actions "${sns_arn}" \
    --dimensions "${dimensions[@]}"
}

########################################
# Get all service ARNs
########################################

echo "Listing ECS services in cluster '${CLUSTER_NAME}'..."
SERVICE_ARNS=$(
  aws ecs list-services \
    --cluster "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" \
    --output text \
    --query 'serviceArns[]' || true
)

if [[ -z "${SERVICE_ARNS}" ]]; then
  echo "No services found in cluster ${CLUSTER_NAME}; nothing to do."
  exit 0
fi

echo "Found services:"
echo "${SERVICE_ARNS}" | tr '\t' '\n'
echo

########################################
# Main loop – per service
########################################

for SERVICE_ARN in ${SERVICE_ARNS}; do
  echo "==============================="
  echo "Processing ECS service ARN:"
  echo "  ${SERVICE_ARN}"

  SERVICE_JSON=$(
    aws ecs describe-services \
      --cluster "${CLUSTER_NAME}" \
      --services "${SERVICE_ARN}" \
      --region "${AWS_REGION}" \
      --profile "${AWS_PROFILE}" \
      --output json
  )

  SERVICE_NAME=$(echo "${SERVICE_JSON}" | jq -r '.services[0].serviceName')
  DESIRED_COUNT=$(echo "${SERVICE_JSON}" | jq -r '.services[0].desiredCount')

  if [[ "${SERVICE_NAME}" == "null" || -z "${SERVICE_NAME}" ]]; then
    echo "  WARNING: could not get serviceName, skipping."
    continue
  fi

  echo "Service name   : ${SERVICE_NAME}"
  echo "Desired count  : ${DESIRED_COUNT}"

  DIM_CLUSTER="Name=ClusterName,Value=${CLUSTER_NAME}"
  DIM_SERVICE="Name=ServiceName,Value=${SERVICE_NAME}"

  ######################################
  # 1) RunningTaskCount LOW (service health)
  ######################################
  if (( DESIRED_COUNT > 0 )); then
    RUNNING_ALARM_NAME="${RESOURCE_PREFIX}-${SERVICE_NAME}-ecs-service-runningtask-low-${DESIRED_COUNT}"
    RUNNING_DESC="ECS service ${SERVICE_NAME}: RunningTaskCount < ${DESIRED_COUNT}"

    create_alarm \
      "${RUNNING_ALARM_NAME}" \
      "${RUNNING_DESC}" \
      "AWS/ECS" \
      "RunningTaskCount" \
      "Minimum" \
      "LessThanThreshold" \
      "${DESIRED_COUNT}" \
      "${SNS_TOPIC_RUNNING_ARN}" \
      "Count" \
      "${DIM_CLUSTER}" "${DIM_SERVICE}"
  else
    echo "  DesiredCount == 0; skipping RunningTaskCount alarm (service intentionally scaled to 0)."
  fi

  ######################################
  # 2) PendingTaskCount HIGH
  ######################################
  PENDING_ALARM_NAME="${RESOURCE_PREFIX}-${SERVICE_NAME}-ecs-service-pendingtask-high-${PENDING_TASK_THRESHOLD}"
  PENDING_DESC="ECS service ${SERVICE_NAME}: PendingTaskCount >= ${PENDING_TASK_THRESHOLD}"

  create_alarm \
    "${PENDING_ALARM_NAME}" \
    "${PENDING_DESC}" \
    "AWS/ECS" \
    "PendingTaskCount" \
    "Maximum" \
    "GreaterThanOrEqualToThreshold" \
    "${PENDING_TASK_THRESHOLD}" \
    "${SNS_TOPIC_PENDING_ARN}" \
    "Count" \
    "${DIM_CLUSTER}" "${DIM_SERVICE}"

  ######################################
  # 3) CPUUtilization HIGH (80%, 90%)
  ######################################
  for CPU_THR in "${CPU_THRESHOLDS[@]}"; do
    CPU_ALARM_NAME="${RESOURCE_PREFIX}-${SERVICE_NAME}-ecs-service-cpu-high-${CPU_THR}%"
    CPU_DESC="ECS service ${SERVICE_NAME}: CPUUtilization >= ${CPU_THR}%"

    create_alarm \
      "${CPU_ALARM_NAME}" \
      "${CPU_DESC}" \
      "AWS/ECS" \
      "CPUUtilization" \
      "Average" \
      "GreaterThanOrEqualToThreshold" \
      "${CPU_THR}" \
      "${SNS_TOPIC_CPU_ARN}" \
      "Percent" \
      "${DIM_CLUSTER}" "${DIM_SERVICE}"
  done

  ######################################
  # 4) MemoryUtilization HIGH (80%, 90%)
  ######################################
  for MEM_THR in "${MEM_THRESHOLDS[@]}"; do
    MEM_ALARM_NAME="${RESOURCE_PREFIX}-${SERVICE_NAME}-ecs-service-memory-high-${MEM_THR}%"
    MEM_DESC="ECS service ${SERVICE_NAME}: MemoryUtilization >= ${MEM_THR}%"

    create_alarm \
      "${MEM_ALARM_NAME}" \
      "${MEM_DESC}" \
      "AWS/ECS" \
      "MemoryUtilization" \
      "Average" \
      "GreaterThanOrEqualToThreshold" \
      "${MEM_THR}" \
      "${SNS_TOPIC_MEM_ARN}" \
      "Percent" \
      "${DIM_CLUSTER}" "${DIM_SERVICE}"
  done

  echo
done

echo "Done creating ECS service CloudWatch alarms."
