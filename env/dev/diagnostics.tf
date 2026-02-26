resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  name                       = "${var.name_prefix}-vm-diag"
  target_resource_id         = azurerm_linux_virtual_machine.vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}