function Backup-ValheimWorld {
    <#
        .SYNOPSIS
        Archives a Valheim world to the provided destination.

        .DESCRIPTION
        Creates a compressed file for Valheim world files, saving them to the provided destination.
        Epoch timestamp appended to filename to avoid clobbering.
        
        .PARAMETER World
        Zero or more strings matching a Valheim world on the current profile.
        Omitting this parameter will create archives for all worlds.

        .PARAMETER Destination
        Required.  A destination directory to save the compressed backup file to.

        .EXAMPLE 
        Backup a Valheim world titled "Midgaard" to a directory titled WorldBackup in the default Valheim folder
        C:\> Backup-ValheimWorld -World "Midgaard" -Destination $env:APPDATA\LocalLow\IronGate\Valheim\WorldBackup
        
        .OUTPUTS
        The cmdlet only returns a FileInfo object when you use the PassThru parameter. 
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(position=0,ValueFromPipeline)]
        [System.String[]]$World = (Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\worlds\*.db" | Select-Object -ExpandProperty BaseName)
        ,
        [Parameter(position=1)]
        [System.IO.DirectoryInfo]$Destination = [System.IO.DirectoryInfo]"$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Archive\Worlds"
        ,
        [System.Management.Automation.SwitchParameter]$PassThru
    )

    begin {
        if (-not ($Destination.Exists)) {
            if ($PSCmdlet.ShouldProcess("Destination","Creating Archive Directory")) {
                try {
                    New-Item -ItemType Directory -Path $Destination -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    Exit $LASTEXITCODE
                }
            }
        }
        if (-not $World) {
            $World = Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\worlds\*.db" | Select-Object -ExpandProperty BaseName
        }
    }
    process {
        foreach ($w in $World) {
            if ($PSCmdlet.ShouldProcess($w,"Validation")) {
                if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Worlds\$w.db")) {
                    Write-Warning -Message ".db file missing for $w"
                }
                if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Worlds\$w.fwl")) {
                    Write-Warning -Message ".fwl file missing for $w"
                }
            }
            if ($PSCmdlet.ShouldProcess($w,"Archiving")) {
                try {
                    [System.IO.FileInfo[]]$Archive += Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Worlds\$w*" -ErrorAction Stop |
                    Compress-Archive -DestinationPath "$Destination\$w.$(Get-Date -uFormat %s).zip" -CompressionLevel Optimal -ErrorAction Stop -PassThru
                }
                catch {
                    Write-Error $_
                }
            }
        }
    }
    end {
        if ($Archive -and $PassThru) {
            $Archive
        }
    }
}