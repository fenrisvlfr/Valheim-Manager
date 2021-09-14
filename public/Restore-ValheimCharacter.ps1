function Restore-ValheimCharacter {
    <#
        .SYNOPSIS
        Restores a Valheim Character file from an existing backup file.

        .DESCRIPTION
        Renames the current *.fch and *.fch.old files to *.fch.backup and *.fch.old.backup in the Destination directory, respectively.
        Then extracts the character files from an existing archive, loading them to the Destination.

        .PARAMETER Path
        The fullname of a .zip file containing Valheim Character files (*.fch and *.fch.old).

        .PARAMETER Destination
        The 
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position=0,Mandatory,ValueFromPipeline)]
        $Character
        ,
        [Parameter(Position=1)]
        [System.IO.DirectoryInfo]$Destination = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\characters"
        ,
        [Parameter(Position=2)]
        $Path = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\Archive\characters"
    )

    begin {
        if (-not ($Destination.Exists)) {
            if ($PSCmdlet.ShouldProcess("Destination","Creating Restoration Directory")) {
                try {
                    New-Item -ItemType Directory -Path $Destination -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    Exit $LASTEXITCODE
                }
            }
        }
    }
    process {
        switch ($true) {
            (($Character.GetType() -eq "System.IO.FileInfo") -and (Test-Path $Character)) {
                $Path = $Character
            }
            ($Character.GetType() -eq "System.String" -and ($Path.GetType() -eq "System.IO.DirectoryInfo")) {
                $Path = Get-ChildItem $Path | Where-Object -FilterScript {$_.name -like "$Character*"} | Sort-Object -Property BaseName -Descending | Select-Object -First 1
            }
            default {
                try {
                    $Character.GetType()
                }
                catch {
                    
                }
            }
        }

    }
    end {}
}