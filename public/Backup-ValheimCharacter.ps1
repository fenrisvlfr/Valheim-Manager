function Backup-ValheimCharacter {
    <#
        .SYNOPSIS
        Archives a Valheim character to the provided location.

        .DESCRIPTION
        Creates a compressed file for Valheim character files, saving them to the provided destination.
        Epoch timestamp appended to filename to avoid clobbering.

        .NOTES
        Author: Matthew Siler <silertech@gmail.com>

        .PARAMETER Character
        Zero or more strings matching a Valheim character on the current profile.
        Omitting this parameter will create archives for all characters.

        .PARAMETER Destination
        Required.  A destination directory to save the compressed backup file to.

        .EXAMPLE 
        Backup a Valheim characger named "Egdar" to a directory titled CharacterBackup in the default Valheim folder
        C:\> Backup-ValheimCharacter -Character "Egdar" -Destination $env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\CharacterBackup
        
        .OUTPUTS
        The cmdlet only returns a FileInfo object when you use the PassThru parameter. 
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(position=0,ValueFromPipeline)]
        [System.String[]]$Character = (Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\*fch" | Select-Object -ExpandProperty BaseName)
        ,
        [Parameter(position=1)]
        [System.IO.DirectoryInfo]$Destination = [System.IO.DirectoryInfo]"$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Archive\Characters"
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
        if (-not $Character) {
            $Character = Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\*fch" | Select-Object -ExpandProperty BaseName
        }
    }
    process {
        foreach ($c in $Character) {
            if ($PSCmdlet.ShouldProcess($c,"Validation")) {
                if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$c.fch")) {
                    Write-Warning -Message ".fch file missing for $c"
                }
                if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$c.fch.old")) {
                    Write-Warning -Message ".fch.old file missing for $c"
                }
            }
            if ($PSCmdlet.ShouldProcess($c,"Archiving")) {
                try {
                    [System.IO.FileInfo[]]$Archive += Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$c*" -ErrorAction Stop |
                    Compress-Archive -DestinationPath "$Destination\$c.$(Get-Date -uFormat %s).zip" -CompressionLevel Optimal -ErrorAction Stop -PassThru
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
            Remove-Variable Archive
        }
    }
}