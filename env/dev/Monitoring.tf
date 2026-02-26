
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30
}


resource "azurerm_monitor_data_collection_rule" "dcr_syslog" {
  name                = "${var.name_prefix}-dcr-syslog"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  destinations {
    log_analytics {
      name                  = "law-dest"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  data_sources {
    syslog {
      name           = "syslog-source"
      facility_names = ["*"]
      log_levels     = ["Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law-dest"]
  }
}


resource "azurerm_virtual_machine_extension" "ama_linux" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}


resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc_vm" {
  name                    = "${var.name_prefix}-dcr-assoc"
  target_resource_id      = azurerm_linux_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_syslog.id

  depends_on = [azurerm_virtual_machine_extension.ama_linux]
}