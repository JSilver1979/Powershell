$env:UserName
$env:ComputerName
$PathToInfo = "" # Указать имя сетевой папки, куда будут писаться логи
$LogTime = Get-Date -Format "dd/MM/yyyy HH:mm"
$LogString = $env:UserName + ";" + $LogTime
$LogString | Out-File -FilePath $PathToInfo$env:ComputerName