Function GetAuditPolicy([string]$Category,[string]$Subcategory) {
    If (Test-RunAsAdmin){
        auditpol /get /category:$Category |
            Where-Object -FilterScript {$_ -match "^\s+$Subcategory"} | 
                ForEach-Object -Process {($_.trim() -split "\s{2,}")[1]}
    } Else {
        Throw "You must run as Administrator to test AuditPolicy"
    }
}
