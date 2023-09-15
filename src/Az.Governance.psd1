# Module manifest for AzGovernance module

@{
  # Script module or binary module file associated with this manifest.
  RootModule = 'Az.Governance.psm1'

  # Version number of this module.
  ModuleVersion = '1.0.0'

  # Author of this module
  Author = 'André'

  # Copyright statement for this module
  Copyright = '(c) 2023 AzFinOps'

  # Description of the functionality provided by this module
  Description = 'This module provides functions for managing Azure Governance.'

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules = @(
    'Az.Accounts',
    'Az.Resources'
  )

  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion = '7.0'

  # Specifies the functions to export from this module
  FunctionsToExport = @(
    'Get-AzGovernanceAccess'
  )

  # Specifies the cmdlets to export from this module
  CmdletsToExport = @()

  # HelpInfo URI of this module
  HelpInfoURI = 'https://github.com/AzFinOps/AzGovernance'
}