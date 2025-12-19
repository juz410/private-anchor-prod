import json
import os
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from typing import Any, Dict, Tuple

import boto3

sns = boto3.client("sns")


class SafeDict(dict):
    def __missing__(self, key: str) -> str:
        return "n/a"


def _resolve_topic_arn(state: str | None, topic_map: Dict[str, str], mapping: Dict[str, str], default_label: str | None) -> str:
    label = None
    if state:
        upper = state.upper()
        lower = state.lower()
        label = mapping.get(upper) or mapping.get(lower)
    if not label and default_label:
        label = default_label
    if not label and topic_map:
        label = next(iter(topic_map.keys()))
    arn = topic_map.get(label or "")
    if not arn:
        raise ValueError(f"No SNS topic mapping found for state '{state}' and label '{label}'")
    return arn


def _get_template(env_key: str, default: str) -> str:
    val = os.environ.get(env_key)
    if val:
        return val
    return default


def _tz_label(offset_minutes: int) -> str:
    if offset_minutes == 0:
        return "UTC"
    sign = "+" if offset_minutes > 0 else "-"
    mins = abs(offset_minutes)
    hours, rem = divmod(mins, 60)
    if rem:
        return f"UTC{sign}{hours:02d}:{rem:02d}"
    return f"UTC{sign}{hours}"


def _format_iso(ts: str | None, tzinfo: timezone, label: str | None) -> str | None:
    if not ts:
        return ts
    try:
        # Normalize 'Z' to '+00:00' for fromisoformat
        norm = ts.replace("Z", "+00:00")
        dt = datetime.fromisoformat(norm)
        target = dt.astimezone(tzinfo)
        tzlabel = label
        return target.strftime(f"%Y-%m-%d, %H:%M ({tzlabel})")
    except Exception:
        return ts


def _split_iso(ts: str | None, tzinfo: timezone, label: str | None) -> Tuple[str | None, str | None]:
    """Return separate date and time strings for the given ISO timestamp."""
    if not ts:
        return ts, ts
    try:
        norm = ts.replace("Z", "+00:00")
        dt = datetime.fromisoformat(norm)
        target = dt.astimezone(tzinfo)
        tzlabel = label
        return target.strftime("%Y-%m-%d"), target.strftime(f"%H:%M ({tzlabel})")
    except Exception:
        return ts, ts


def _timezone_from_env() -> Tuple[timezone, str]:
    """Resolve target timezone from IANA name first, else offset."""
    tz_name = os.environ.get("TIMEZONE_NAME")
    offset_minutes = int(os.environ.get("TIMEZONE_OFFSET_MINUTES", "0"))
    label = os.environ.get("TIMEZONE_LABEL")

    if tz_name:
        try:
            tzinfo = ZoneInfo(tz_name)
            return tzinfo, label or tz_name
        except Exception:
            # Fall back to offset if the name is invalid or unavailable
            pass

    tzinfo = timezone(timedelta(minutes=offset_minutes))
    return tzinfo, label or _tz_label(offset_minutes)


def _build_backup_context(event: Dict[str, Any]) -> SafeDict:
    detail = event.get("detail", {}) or {}
    created_by = detail.get("createdBy", {}) or {}

    ctx = SafeDict({
        "accountId": event.get("account"),
        "region": event.get("region"),
        "time": event.get("time"),
        "state": detail.get("state"),
        "vault": detail.get("backupVaultName"),
        "resourceType": detail.get("resourceType"),
        "resourceName": detail.get("resourceName"),
        "resourceArn": detail.get("resourceArn"),
        "jobId": detail.get("backupJobId"),
        "planName": created_by.get("backupPlanName"),
        "ruleName": created_by.get("backupRuleName"),
        "startTime": detail.get("initiationDate"),
        "completionTime": detail.get("completionDate"),
        "messageCategory": detail.get("messageCategory"),
        "detail_json": json.dumps(detail, default=str),
        "event_json": json.dumps(event, default=str),
        "project_id": os.environ.get("PROJECT_ID", "n/a"),
        "environment": os.environ.get("ENVIRONMENT", "n/a"),
    })
    return ctx


def _build_ec2_context(event: Dict[str, Any]) -> SafeDict:
    detail = event.get("detail", {}) or {}

    ctx = SafeDict({
        "accountId": event.get("account"),
        "region": event.get("region"),
        "time": event.get("time"),
        "state": detail.get("state"),
        "source": event.get("source"),  # e.g., "aws.ec2"
        "resource": event.get("resources", [None])[0],  # e.g., ["arn:aws:ec2:..."]
        "instanceId": detail.get("instance-id"),
        "detail_json": json.dumps(detail, default=str),
        "event_json": json.dumps(event, default=str),
        "project_id": os.environ.get("PROJECT_ID", "n/a"),
        "environment": os.environ.get("ENVIRONMENT", "n/a"),
    })
    return ctx


def _resolve_event_kind(event: Dict[str, Any]) -> Tuple[str, str | None, str | None]:
    source = event.get("source")
    detail_type = event.get("detail-type")
    if source == "aws.backup" and detail_type == "Backup Job State Change":
        return "backup", source, detail_type
    if source == "aws.ec2" and detail_type == "EC2 Instance State-change Notification":
        return "ec2", source, detail_type
    return "unknown", source, detail_type


def handler(event: Dict[str, Any], _context: Any) -> Dict[str, Any]:
    kind, _, _ = _resolve_event_kind(event)

    tzinfo, tz_label = _timezone_from_env()

    topic_map = json.loads(os.environ.get("SNS_TOPIC_MAP", "{}"))

    if kind == "ec2":
        subject_template = _get_template("EC2_SUBJECT_TEMPLATE", "[EC2 State: {state}] Project {project_id}-{environment} at {time_date}")
        message_template = _get_template(
            "EC2_MESSAGE_TEMPLATE",
            (
                "[EC2 {state}]\n"
                "Project ID: {project_id}, Environment: {environment}\n"
                "Account: {accountId}\n"
                "Compute Type: {source}\n"
                "Instance ID: {instanceId}\n"
                "Resource ARN: {resource}\n"
                "Account: {accountId}\n"
                "Region: {region}\n"
                "Time: {time_fmt}\n"
                "\n"
                "\n"
                "Event Source (JSON): {event_json}\n"
                "Detail (JSON): {detail_json}"
            ),
        )
        state_mapping = json.loads(os.environ.get("EC2_STATE_TOPIC_MAPPING", "{}"))
        default_label = os.environ.get("EC2_STATE_TOPIC_LABEL") or os.environ.get("DEFAULT_TOPIC_LABEL")
        ctx = _build_ec2_context(event)
        ctx["time_fmt"] = _format_iso(ctx.get("time"), tzinfo, tz_label)
        ctx["time_date"], ctx["time_time"] = _split_iso(ctx.get("time"), tzinfo, tz_label)
    else:
        subject_template = _get_template("SUBJECT_TEMPLATE", "[BACKUP - {state}] : Project {project_id}-{environment} at {startTime_date}")
        message_template = _get_template(
            "MESSAGE_TEMPLATE",
            (
                "[Backup {state}]\n"
                "Project ID: {project_id}, Environment: {environment}\n"
                "Account: {accountId}\n"
                "Vault: {vault}\n"
                "Resource: ({resourceType}) {resourceName}\n"
                "Resource ARN: {resourceArn}\n"
                "Plan: {planName} (Rule: {ruleName})\n"
                "Backup Job ID: {jobId}\n"
                "Start: {startTime_fmt}\n"
                "End: {completionTime_fmt}\n"
                "Category: {messageCategory}\n"
                "\n"
                "\n"
                "Detail (JSON): {detail_json}"
            ),
        )
        state_mapping = json.loads(os.environ.get("AWSBACKUP_STATE_TOPIC_MAPPING", "{}"))
        default_label = os.environ.get("DEFAULT_TOPIC_LABEL")
        ctx = _build_backup_context(event)
        ctx["time_fmt"] = _format_iso(ctx.get("time"), tzinfo, tz_label)
        ctx["time_date"], ctx["time_time"] = _split_iso(ctx.get("time"), tzinfo, tz_label)
        ctx["startTime_fmt"] = _format_iso(ctx.get("startTime"), tzinfo, tz_label)
        ctx["startTime_date"], ctx["startTime_time"] = _split_iso(ctx.get("startTime"), tzinfo, tz_label)
        ctx["completionTime_fmt"] = _format_iso(ctx.get("completionTime"), tzinfo, tz_label)
        ctx["completionTime_date"], ctx["completionTime_time"] = _split_iso(ctx.get("completionTime"), tzinfo, tz_label)

    state = ctx.get("state")
    topic_arn = _resolve_topic_arn(state, topic_map, state_mapping, default_label)

    try:
        subject = subject_template.format_map(ctx)
    except Exception:
        subject = f"Backup {state or 'UNKNOWN'}"

    # SNS Subject limit is 100 chars
    if len(subject) > 100:
        subject = subject[:97] + "..."

    try:
        message = message_template.format_map(ctx)
    except Exception:
        message = ctx.get("event_json", "{}")

    response = sns.publish(TopicArn=topic_arn, Subject=subject, Message=message)

    return {
        "status": "published",
        "topic": topic_arn,
        "state": state,
        "subject": subject,
        "messageId": response.get("MessageId"),
    }
