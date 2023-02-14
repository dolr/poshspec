$ModuleManifestName = 'poshspec.psd1'
Import-Module $PSScriptRoot\..\$ModuleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' -TestCases @{ ModuleManifestName = 'poshspec.psd1' } {
        Test-ModuleManifest -Path $PSScriptRoot\..\$ModuleManifestName
        $? | Should -Be $true
    }
}

Describe 'Services' {    
    Service w32time Status { Should -Be 'Running' } 
    Service bits Status { Should -Be 'Stopped' }

    It 'test BFE service' {
        Get-Service -Name 'BFE' | Select-Object -ExpandProperty 'Status' | Should -Be 'Running'
    }   
}

Describe 'User Rights Assignment' {
    UserRightsAssignment ByRight 'SeNetworkLogonRight' { 
        Should -Be @("BUILTIN\Users","BUILTIN\Administrators") 
    }

    UserRightsAssignment ByRight 'SeCreatePagefilePrivilege' { 
        Should -Be "BUILTIN\Administrators"
    }

}

Describe 'Audit Policy' {

    AuditPolicy System 'Security System Extension' { Should -Be Success }

    AuditPolicy 'Logon/Logoff' 'Logon' { Should -Be 'Success and Failure' }
}

Describe 'Registries' {

    Registry 'HKLM:\Software\Policies\Microsoft\Windows\Personalization' 'NoLockScreenCamera' {
        Should -Be 1 -Because 'whatever'
    }

    Registry 'HKLM:\SOFTWARE\Microsoft\Rpc\ClientProtocols' { Should -Exist }

}

Describe 'Security Options' {
    SecurityOption 'Accounts: Administrator account status' {
        Should -Be 'Disabled'
    }

    SecurityOption 'Accounts: Guest account status' {
        Should -Be 'Enabled'
    }
}
