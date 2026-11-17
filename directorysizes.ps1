#Obliczenie zajętości katalogu i inne funkcje
function Format-Size {
   param(
      [double]$size
   )
   if ($size -eq 0) {
      return "0 B";
   }
   $przyrostek = @("B", "KB", "MB", "GB", "TB");
   $dzielnik = 1TB
   for($licznik = 4; $licznik -ge 0; $licznik--) {
      if(([Math]::Floor($size/$dzielnik) -ge 1) -or ($licznik -eq 0))
      {
         return "$([Math]::Round($size/$dzielnik,2)) $($przyrostek[$licznik])";
      }
      $dzielnik /= 1KB;
   }
}
function Measure-Size {
   param(
      [string]$path = $null,
      [bool]$recurse = $false
   )
   if (($path -eq $null) -or (-not (test-path $path -PathType Container))) {
      Write-Host "A directory -path $path does not exists or is null";
      return 0;
   }
   $size = 0;
   if ($recurse) {
      $size = (Get-ChildItem $path -file -recurse | Measure-Object -property length -sum).Sum;
   }
   else {
      $size = (Get-ChildItem $path -file | Measure-Object -property length -sum).Sum;
   }
   Write-Host "Size of $path -> $(Format-Size -size $size)";
   return $size;
}

#Sprawdzenie czy to katalog
if ((-not (test-path $($args[0]) -pathtype Container)) -or ($args.Count -eq 0)) {
   write-host "A directory $($args[0]) does not exists";
   exit 1;
}

#Pliki w katalogu głównym
$totalsize = 0;
$size = (Get-ChildItem $($args[0]) -file | Measure-Object -property length -sum).Sum;
write-host "Size of $($args[0]) -> $(Format-Size -size $size) MB";
$totalsize += $size;

#Pobranie zajętości katalogów
$katalogi = (Get-ChildItem $($args[0]) -directory);
foreach ($katalog in $katalogi) {
   $totalsize += Measure-Size -path $katalog.FullName -recurse $true;
}

#Wyświetlenie całkowitej zawartości
write-host "Total size of directory $($args[0]) is $(Format-Size -size $totalsize)";
exit 0;