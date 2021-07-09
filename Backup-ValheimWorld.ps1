function Backup-ValheimWorld {
    <#
        .SYNOPSIS
        Archives a Valheim world to the provided destination.

        .DESCRIPTION
        Creates a compressed file for Valheim world files, saving them to the provided destination.

        .NOTES
        Author: Matthew Siler <silertech@gmail.com>

        .PARAMETER World
        Zero or more strings matching a Valheim world on the current profile.  Omitting this parameter will create archives for all worlds.

        .PARAMETER Destination
        Required.  A destination directory to save the compressed backup file to.

        .EXAMPLE 
        Backup a Valheim world titled "Midgaard" to a directory titled WorldBackup in the default Valheim folder
        C:\> Backup-ValheimWorld -World "Midgaard" -Destination $env:APPDATA\LocalLow\IronGate\Valheim\WorldBackup
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(position=0,ValueFromPipeline)]
        [string[]]$World
        ,
        [Parameter(mandatory,position=1)]
        [System.IO.DirectoryInfo]$Destination = [System.IO.DirectoryInfo]"$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Archive\Worlds"
    )

    begin {
        if (-not ($Destination.Exists)) {
            if ($PSCmdlet.ShouldProcess("Destination","Creating Archive Directory")) {
                try {
                    New-Item -ItemType Directory -Path $Destination -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    Exit 1
                }
            }
        }
    }
    process {
        if ($World) {
            if ($PSCmdlet.ShouldProcess($World,"Validation")) {
                if (-not (Test-Path "$env:APPDATA\LocalLow\IronGate\Valheim\Worlds\$World.db")) {
                    Write-Warning -Message ".db file missing for $World"
                }
                if (-not (Test-Path "$env:APPDATA\LocalLow\IronGate\Valheim\Worlds\$World.fwl")) {
                    Write-Warning -Message ".fwl file missing for $World"
                }
            }
            try {
                Get-ChildItem "$env:APPDATA\LocalLow\IronGate\Valheim\Worlds\$World*" -ErrorAction Stop |
                Compress-Archive -DestinationPath "$Destination\$World.$(Get-Date -uFormat %s).zip" -CompressionLevel Optimal -ErrorAction Stop
            }
            catch {
                Write-Error $_
            }
        }
    }
    end {

    }
}