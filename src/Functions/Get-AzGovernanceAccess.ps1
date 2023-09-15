function Get-AzGovernanceAccess {
  <#
  .SYNOPSIS
    Extract a report of Azure access.

  .DESCRIPTION
    The Get-AzGovernanceAccess will create a csv with all access in your Azure
    estate.

  .PARAMETER SubscriptionId
    Subscription ID of where information is going to be extracted from. If empty,
    it will retrieve for all subscriptions.

  .PARAMETER OutputPath
    Path where the file will be extracted to.

  .EXAMPLE
    Get-AzGovernanceAccess
    Extract all access information.

  .EXAMPLE
    Get-AzGovernanceAccess -OutputPath "C:\Temp"
    Extract access information into a specified path.

  .EXAMPLE
    Get-AzGovernanceAccess -Subscription "ca34a07e-27a2-4031-8e48-e9043952b967" -OutputPath "C:\Temp"
    Extract access information from a specific subscription into a specified folder.

  .LINK
    https://github.com/AzFinOps/AzGovernance/wiki
  #>

  param (
    [string] $SubscriptionId,
    [string] $OutputPath = "."
  )

  function Get-AzureAccess {
    $localReport = [System.Collections.Concurrent.ConcurrentBag[PSCustomObject]]@()
    $subscriptionId = (Get-AzContext).Subscription.Id
    $subscriptionName = (Get-AzContext).Subscription.Name
    
    $access = Get-AzRoleAssignment
    $access | Foreach-Object -ThrottleLimit 5 -Parallel {
      $localReport = $using:localReport

      $scopeCheck = $_.Scope.Split("/")

      if ($scopeCheck -contains "managementGroups") {
        $type = "Management Group"
      } else {
        switch ($scopeCheck.Count) {
          {$_ -ge 8} { $type = "Resource"; break }
          {$_ -eq 5} { $type = "Resource Group"; break }
          {$_ -eq 3 }{ $type = "Subscription"; break }
          Default { $type = "Unknown"}
        }
      }

      $scope = $_.Scope
      $subscriptionId = $using:subscriptionId
      $subscriptionName = if ($type -ne "Management Group") {
        $using:subscriptionName
      } else {
        $null
      }

      $resourceGroup = if ($type -eq "Resource" -or $type -eq "Resource Group") {
        $_.Scope.Split("/")[4]
      } else {
        $null
      }

      $resource = if ($type -eq "Resource") {
        $_.Scope.Split("/")[-1]
      } else {
        $null
      }

      $localReport.Add([PSCustomObject]@{
        ObjectType = $_.ObjectType
        ObjectId = $_.ObjectId
        DisplayName = $_.DisplayName
        Name = $_.SignInName
        RoleDefinitionName = $_.RoleDefinitionName
        Scope = $type
        SubscriptionName = $subscriptionName
        SubscriptionId = $subscriptionId
        ResourceGroup = $resourceGroup
        Resource = $resource
        Id = $scope
      })
    }
    return $localReport
  }

  # Declare variables
  $report = @()
  $timestamp = Get-Date -Format "yyyyMMdd-HHmm"

  if ($SubscriptionId) {
    Set-AzContext $SubscriptionId | Out-Null
    $report += Get-AzureAccess
  } else {
    $subscriptions = Get-AzSubscription
    foreach ($subscription in $subscriptions) {
      Set-AzContext $subscription | Out-Null
      $report += Get-AzureAccess
    }
  }
  $report | Export-Csv -Path "$OutputPath/Governance-Access-$timestamp.csv" -NoTypeInformation
}