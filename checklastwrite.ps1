#Program do analizy ostatnio zapisanych plików
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
                if($script:downer) {
                    Write-Host("You can use -owner parameter one time");
                    exit 1;
                }
                $script:downer = $true;
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
    else {
        return $true;
    }
}

#Program
$script:ddate = (Get-Date);
$script:dpath = "";
$script:downer = $false;
if (-not(Get-Args -params $args)) {
    Write-Host "Error: Wrong parameters";
    exit 1;
}
Write-Host "Selected limit past time: $($script:ddate.ToString("F"))";
Write-Host "Get owner of files: $script:downer";
exit 0;