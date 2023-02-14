function GetSecurityPolicy([string]$Category) {

    function Get-PolicyOptionData {
        [OutputType([hashtable])]
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory = $true)]
            [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
            [hashtable]
            $FilePath
        )
        return $FilePath
    }

    $securityOptionData = Get-PolicyOptionData -FilePath $("$PSScriptRoot\SecurityOptionData.psd1").Normalize()
    
    $SecurityOption = $securityOptionData[$Category]

    If ($SecurityOption) {

        $SecurityPolicyFilePath = Join-Path -Path $env:temp -ChildPath 'SecurityPolicy.inf'
        secedit.exe /export /cfg $SecurityPolicyFilePath /areas 'SECURITYPOLICY' | Out-Null

        $policyConfiguration = @{ }

        switch -regex -file $SecurityPolicyFilePath {
            "^\[(.+)\]" {
                # Section
                $section = $matches[1]
                $policyConfiguration[$section] = @{ }
            }
            "(.+?)\s*=(.*)" {
                # Key
                $name, $value = $matches[1..2] -replace "\*"
                $policyConfiguration[$section][$name] = $value.Trim()
            }
        }

        $soSection = $SecurityOption.Section
        $soOptions = $SecurityOption.Option
        $soValue = $SecurityOption.Value                

        $soResultValue = $policyConfiguration.$soSection.$soValue

        If ($soResultValue) {

            If ($soOptions.GetEnumerator().Name -ne 'String') {
                $soResult = ($soOptions.GetEnumerator() | Where-Object { $_.Value -eq $soResultValue }).Name
            } 
            Else {
                $soOptionsValue = ($soOptions.GetEnumerator() | Where-Object { $_.Name -eq 'String' }).Value
                $soResult = $soResultValue -Replace "^$soOptionsValue", ''
            }
        }
        Else {
            $soResult = $null
        }

        Return $soResult
    }
    Else {
        Throw "The security option $Category was not found."
    }
}