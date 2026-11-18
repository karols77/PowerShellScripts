#Program do wyszukiwania ostatnio zapisanych plików
#Analiza argumentów
function Get-Args {
    param(
        [string[]]$params
    )
    if ($params.Count -lt 4) {
        Write-Host "Not -path and (-day nor -hour nor -minute arguments)"
        exit 1;
    }
    $dateOK = $false;
    $pathOK = $false;
    for ($i = 0; $i -lt $params.Count; $i++) {
        switch ($($params[$i])) {
            "-path" {
                $i++;
                if (($i -ge $params.Count) -or ($script:dpath -ne "")) {
                    Write-Host "Error: Multiple -path param or no path";
                    exit 1;
                }
                $script:dpath = $($params[$i]);
                if (-not (Test-Path -Path $script:dpath -PathType Container)) {
                    Write-Host "Error: Path $script:dpath does nor exists";
                    exit 1;
                }
                $pathOK = $true;
                continue;
            }
            "-days" {
                [uint32]$days = 0;
                $i++;
                if (($i -ge $params.Count) -or (-not ([uint32]::TryParse($params[$i], [ref]$days)))) {
                    Write-Host "Error: -day param musts have non negatice integer argument";
                    exit 1;
                }
                $script:ddate = $script:ddate.AddDays(-$days);
                $dateOK = $true;
                continue;
            }
            "-hours" {
                [uint32]$hours = 0;
                $i++;
                if (($i -ge $params.Count) -or (-not ([uint32]::TryParse($params[$i], [ref]$hours)))) {
                    Write-Host "Error: -hours param musts have non negatice integer argument";
                    exit 1;
                }
                $script:ddate = $script:ddate.AddHours(-$hours);
                $dateOK = $true;
                continue;
            }
            "-minutes" {
                [uint32]$minutes = 0;
                $i++
                if (($i -ge $params.Count) -or (-not ([uint32]::TryParse($params[$i], [ref]$minutes)))) {
                    Write-Host "Error: -minutes param musts have non negative integer argument $minutes";
                    exit 1;
                }
                $script:ddate = $script:ddate.AddMinutes(-$minutes);
                $dateOK = $true;
                continue;
            }
            "-seconds" {
                [uint32]$seconds = 0;
                $i++;
                if (($i -ge $params.Count) -or (-not ([uint32]::TryParse($params[$i], [ref]$seconds)))) {
                    Write-Host "Error: -seconds param musts have non negatice integer argument";
                    exit 1;
                }
                $script:ddate = $script:ddate.AddSeconds(-$seconds);
                $dateOK = $true;
                continue;
            }
            "-owner" {
                if ($script:downer) {
                    Write-Host("You can use -owner parameter one time");
                    exit 1;
                }
                $script:downer = $true;
            }
            "-outfile" {
                $i++;
                if (($i -ge $params.Count) -or ($script:dfile -ne "")) {
                    Write-Host "You can use -outfile one time or there is no file name as argument";
                    exit 1;
                }
                $script:dfile = $($params[$i]);
            }
            "-ownername" {
                $i++;
                if (($i -ge $params.Count) -or ($script:downername -ne "")) {
                    Write-Host "You can use -ownername one time or there is no file name as argument";
                    exit 1;
                }
                $script:downername = $($params[$i]);
            }
            default {
                Write-Host "Wrong parameter: $_";
                exit 1;
            }

        }
    }
    if (-not ($dateOK -and $pathOK)) {
        Write-Host "Not -path and (-day nor -hour nor -minute arguments)";
        return $false;
    }
    if ($script:downername -ne "") {
        $script:downer = $true;
    }
    return $true;
}

function Get-FileListByDate {
    param (
        [string]$path,
        [datetime]$date
    )
    $files = Get-ChildItem $path -file -recurse;
    [System.IO.FileInfo[]]$dfile = $null;
    foreach ($file in $files) {
        if ($file.LastWriteTime -ge $script:ddate) {
            $dfile += $file;
        }
    }
    $dfile = $dfile | Sort-Object LastWriteTime -Descending;
    return $dfile;
}

function Select-Owner {
    param (
        [System.IO.FileInfo[]]$files,
        [string]$ownername
    )
    $nfiles = @();
    foreach ($file in $files) {
        $snfile = [PSCustomObject]@{
            FullName      = $file.FullName
            LastWriteTime = $file.LastWriteTime
            Length        = $file.Length
            Owner         = (Get-Acl $file.FullName).Owner
        };
        if (($ownername -eq "") -or ($snfile.Owner -like $ownername)) {
            $nfiles += $snfile;
        }
    }
    return $nfiles;
}

function Format-FileList {
    param (
        [System.IO.FileInfo[]]$files,
        [bool]$owner,
        [string]$ownername,
        [string]$outfile
    )
    if ($owner) {
        $nfiles = Select-Owner -files $files -ownername $ownername;
        if ($outfile -ne "") {
                $nfiles | Select-Object FullName, LastWriteTime, Length, Owner | Format-Table -AutoSize | Out-File $outfile;
        }
        else {
            $nfiles | Select-Object FullName, LastWriteTime, Length, Owner | Format-Table -AutoSize;
        }
    }
    else {
        if ($outfile -ne "") {
            $files | Select-Object FullName, LastWriteTime, Length | Format-Table -AutoSize | Out-File $outfile;
        }
        else {
            $files | Select-Object FullName, LastWriteTime, Length | Format-Table -AutoSize;
        }
    }
}

#Program
$script:ddate = (Get-Date);
$script:dpath = "";
$script:downer = $false;
$script:dfile = "";
$script:downername = "";
if (-not(Get-Args -params $args)) {
    Write-Host "Error: Wrong parameters";
    exit 1;
}
Write-Host "Selected limit past time: $($script:ddate.ToString("F"))";
Write-Host "Get owner of files: $script:downer";
if ($script:dfile -ne "") {
    Write-Host "Out-File:" $script:dfile;
}
if ($script:downername -ne "") {
    Write-Output "Owner: $script:downername";
}

#Wyświetlenie wyników
$files = Get-FileListByDate -path $script:dpath -date $script:ddate;
Format-FileList -files $files -owner $script:downer -ownername $script:downername -outfile $script:dfile;
exit 0;