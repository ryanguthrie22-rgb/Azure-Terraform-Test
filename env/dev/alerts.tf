# -------------------------
# Alerting
# -------------------------

variable "alert_email" {
  type        = string
  description = "Email address for Azure Monitor alerts"
}

resource "azurerm_monitor_action_group" "ops" {
  name                = "${var.name_prefix}-ag-ops"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "opsag"

  email_receiver {
    name          = "primary"
    email_address = var.alert_email
  }
}

# Log alert: SSH brute-force in Syslog
resource "azurerm_monitor_scheduled_query_rules_alert" "ssh_bruteforce" {
  name                = "${var.name_prefix}-alert-ssh-bruteforce"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Log Analytics workspace
  data_source_id = azurerm_log_analytics_workspace.law.id

  description = "Triggers when SSH brute-force patterns appear in Syslog."
  enabled     = true
  severity    = 2

  # minutes
  frequency   = 5 # run every 5 minutes
  time_window = 5 # look back 5 minutes

  query = <<QUERY
Syslog
| where TimeGenerated > ago(5m)
| where ProcessName == "sshd" or SyslogMessage has "sshd"
| where SyslogMessage has_any ("Failed password", "Invalid user", "Connection closed by invalid user")
| summarize Count = count()
QUERY

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group  = [azurerm_monitor_action_group.ops.id]
    email_subject = "SSH brute-force detected on ${var.vm_name}"
  }
}

# Metric alert: high CPU on VM
resource "azurerm_monitor_metric_alert" "vm_cpu_high" {
  name                = "${var.name_prefix}-alert-vm-cpu-high"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]

  description = "Average CPU > 80% for 5 minutes"
  severity    = 2
  enabled     = true
  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}