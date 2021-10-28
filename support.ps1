function Find-User {
    Clear-Host
    Write-Host "--------------Поиск пользователя-------------------"  -ForegroundColor Green
    Write-Host ""
    $ReadName = Read-Host "Введите ФИО пользователя"
    $ReadName = "*" + $ReadName + "*"
    $UsersInfo = Get-ADUser -Filter 'DisplayName -like $ReadName' -Properties *
    If ($UsersInfo -is [array]) {
        Write-Host ""
        Write-Host "           Найденные пользователи:" -ForegroundColor Green
        Write-Host "---------------------------------------------------"
        Foreach ($user in $UsersInfo) {
            Write-Host "     "$UsersInfo.IndexOf($user) ":" $user.Name -ForegroundColor DarkGray
        }
        Write-Host "---------------------------------------------------"
        $UserIndex = Read-Host "Введите номер пользователя"
        Get-UserInfo($UsersInfo[$UserIndex])

    } elseif (-not ([string]::IsNullOrEmpty($UsersInfo))) {
        Get-UserInfo($UsersInfo)
    } else {
        Write-Host ""
        Write-Host "----------- Пользователь не найден ----------------" -ForegroundColor Red
        Write-Host ""
        Get-ActionsMenu("Main")
    }
}

function Get-UserInfo ($User) {
    Write-Host ""
    Write-Host "           Информация о пользователе:" -ForegroundColor Green
    Write-Host "---------------------------------------------------"
    Write-Host "            ФИО: "$User.DisplayName
    Write-Host "          Логин: "$User.SamAccountName
    Write-Host "      Должность: "$User.Title
    Write-Host "  Подразделение: "$User.Department
    Write-Host "          Адрес: "$User.StreetAddress
    Write-Host "           Офис: "$User.physicalDeliveryOfficeName
    Write-Host "          Почта: "$User.mail
    Write-Host "       Моб. тел: "$User.mobile
    Write-Host "     Внутр. тел: "$User.telephoneNumber
    Write-Host "            SID: "$User.SID
    If ($User.PasswordNeverExpires) {
        Write-Host "         Пароль:  Никогда не истекает" -ForegroundColor DarkYellow
    } ElseIf (-not $User.PasswordExpired) {
        Write-Host "         Пароль:  Истекает"(Get-Date($User.PasswordLastSet).adddays(120))
    } Else {
        Write-Host "         Пароль:  Истек." -ForegroundColor Red
    }
    If ($User.LockedOut) {
        Write-Host " Учетная запись:  Заблокирована" -ForegroundColor Red
    }
    If (-not $User.Enabled) {
        Write-Host " Учетная запись:  Отключена" -ForegroundColor Red
    }
    Get-PCName ($User.SamAccountName)
}

function Get-PCName ($LoggedOnUser) {
    $PathToInfo = "" # указать путь к папке, где лежат файлы скрипта log-pc-users
    $logFile = Get-ChildItem -Path $PathToInfo -Recurse | Select-String $LoggedOnUser -List
    If ($logFile -is [array]) {
        ForEach ($foundPC in $logFile) {
            $ThisPC = $foundPC | Select Path |Split-Path -leaf
            $logArray = ($foundPC.Line.ToString()).Split(";")
            Write-Host "      Компьютер:  $ThisPC," $logArray[1] -ForegroundColor Cyan
        }
        Get-ActionsMenu("Main")
    } ElseIf (-not ([string]::IsNullOrEmpty($LogFile))) {
        $ThisPC = $logFile | Select Path |Split-Path -leaf
        $logArray = ($logFile.Line.ToString()).Split(";")

        Write-Host "      Компьютер:  $ThisPC," $logArray[1] -ForegroundColor Cyan
        Get-ActionsMenu("OnePC")
    } Else {
        Write-Host "      Компьютер:  не найден" -ForegroundColor Red
    }

}

function Get-ActionsMenu ($menuChoice) {
    If ($menuChoice -eq "Main") {
        Write-Host ""
        Write-Host "   Вас приветствует помощник службы техподдержки" -ForegroundColor Green
        Write-Host "---------------------------------------------------"
        Write-Host "               Возможные действия:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1 - Найти информацию о пользователе" -ForegroundColor Yellow
        Write-Host "2 - Запустить удаленное подключение без привязки к ПК"  -ForegroundColor Yellow
        Write-Host "3 - Выйти из программы"  -ForegroundColor Yellow
        Write-Host "---------------------------------------------------"
        $StartMenu = Read-Host "Введите номер действия"
        Switch ($StartMenu)
        {
            1 {Find-User}
            2 {cmd /c msra /offerra}
            3 {Exit}
        }
    } ElseIf ($menuChoice -eq "OnePC") {
        Write-Host "---------------------------------------------------"
        Write-Host "               Возможные действия:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1 - Подключиться к компьютеру $ThisPC" -ForegroundColor Yellow
        Write-Host "2 - Запустить удаленное подключение без привязки к ПК"  -ForegroundColor Yellow
        Write-Host "3 - Найти другого пользователя"  -ForegroundColor Yellow
        Write-Host "4 - Выйти из программы"  -ForegroundColor Yellow
        Write-Host "---------------------------------------------------"
        $ChooseNum = Read-Host "Введите номер действия"
        Switch ($ChooseNum) {
            1 {cmd /c msra /offerra $ThisPC}
            2 {cmd /c msra /offerra}
            3 {Find-User}
            4 {Exit}
        }
    }
}

Clear-Host
DO {
    Get-ActionsMenu("Main")
} While ($true)

