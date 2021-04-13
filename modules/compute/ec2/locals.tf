locals {

  alarms = var.create_default_ec2_alarms ? {
    for idx, alarm in var.ec2_alarms:
    idx => {
      alarm_name : alarm["alarm_name"]
      comparison_operator : alarm["comparison_operator"]
      evaluation_periods : alarm["evaluation_periods"]
      metric_name : alarm["metric_name"]
      namespace : alarm["namespace"]
      period : alarm["period"]
      statistic : alarm["statistic"]
      threshold : alarm["threshold"]
      alarm_description : alarm["alarm_description"]
    }
  } : {}

}