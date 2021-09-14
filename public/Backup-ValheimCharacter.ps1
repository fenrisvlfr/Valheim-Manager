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
        [ValidateScript({Test-Path "$env:USERPROFILE\AppdData\LocalLow\IronGate\Valheim\characters\$_.fch"})]
        [System.String[]]$Character = (Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\*.fch").BaseName
        ,
        [Parameter(position=1,mandatory)]
        [System.IO.DirectoryInfo]$Destination = [System.IO.DirectoryInfo]"$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Archive\Characters"
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
            [System.Array]$Character = Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\*fch" | Select-Object -ExpandProperty BaseName
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess($Character,"Validation")) {
            if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$Character.fch")) {
                Write-Warning -Message ".fch file missing for $Character"
            }
            if (-not (Test-Path "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$Character.fch.old")) {
                Write-Warning -Message ".fch.old file missing for $Character"
            }
        }
        try {
            Get-ChildItem "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters\$Character*" -ErrorAction Stop |
            Compress-Archive -DestinationPath "$Destination\$Character.$(Get-Date -uFormat %s).zip" -CompressionLevel Optimal -ErrorAction Stop -PassThru -OutVariable Archive
        }
        catch {
            Write-Error $_
        }
    }
    end {
        if ($Archive -and $PassThru) {
            $Archive
        }
    }
}