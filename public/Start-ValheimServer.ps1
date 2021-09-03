Function Start-ValheimServer {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $Name
        ,
        [Parameter()]
        [System.Int32]
        $Port = 2456
        ,
        [Parameter(Mandatory)]
        [System.String]
        $World
        ,
        [Parameter(Mandatory)]
        [System.String]
        $Password
    )

    if (Get-Process valheim_server | Where-Object {$_.MainWindowTitle -like "*$ServerName"}){
        Write-Host "Named server is already running."
    }
    else {
        $env:SteamAppID=892970
        # NOTE: Minimum password length is 5 characters & Password cant be in the server name.
        # NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
        Start-Process -FilePath $PSScriptRoot\valheim_server.exe -ArgumentList "-nographics -batchmode -name `"$Name`" -port $Port -world `"$World`" -password `"$Password`""        
    }
}

