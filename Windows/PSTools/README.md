# Описание (будет дополняться)

Собираю различные решения, которые помогли мне в работе.

## Об автоматизации работы

В начале моей работы в ТехАрт (2019 год) могло быть по 10 выходов новых сотрудников на работы в неделю, кажется что не особо много, но сейчас, смотря на это с середины 2024 года кажется очень много)

В общем, кроме задач по подготовке новых устройств, была также рабочаю рутина по стандартным моментам, такие как - установка новых программ, принтеров и тому подобное.

С этого момента начался процесс по автоматизации части работы. Далее я опишу как это происходило. Часть из всего этого уже не актуально, но такие моменты интересно вспоминать.

Впоследствии все сформировалось в программу на C#, но ниже буду описывать сами скрипты. 

### Подключение к Windows-машинам через cmd

Пусть мой начался со следующего набора программ [PSTools](https://learn.microsoft.com/ru-ru/sysinternals/downloads/pstools), а если быть точнее то с [PsExec]{https://learn.microsoft.com/ru-ru/sysinternals/downloads/psexec}.

С помощью всего пары ключей можно подключится к другой Windows-машине через cmd или powershell, как кому удобнее:
```
PsExec.exe -u [user] -h \\[ip-address] cmd
```
Также так можно удаленно менять пароль на локальной УЗ на удаленном устройстве - `net user Administrator $pass$`, `$pass$` - тут вводите пароль в открытом виде, поэтому такой способ не рекомендую.

### Удаленная установка принтера на устройство
Как я и писал выше, мой экскур начался с установки принтеров на устройства. В моем случае мне повезло, тк принтера был Kyocera и все приблизительно одной модели, так что в результате все сформировалось в пару скриптов.

Первый - скачивает на устройство драйвера и необходимый набор файлов с сетевой шары `install.bat`:
```
@echo off
mkdir c:\temp
c:\windows\system32\xcopy /Y /Z /R /E "\\[ip-address]\KXDriver2040\64bit\XP and newer\*" "c:\temp\KXDriver2040\64bit\XP and newer\"
c:\windows\system32\xcopy /Y /Z /R \\[ip-address]\!bat\printer.ps1 c:\temp
c:\windows\system32\xcopy /Y /Z /R \\[ip-address]\!bat\setup_printer.bat c:\temp
c:\temp\setup_printer.bat
pause
exit
```

Файл `setup_printer.bat` - необходим для разрешения запуска powershell-скрипта
```
Powershell.exe -executionpolicy Bypass -File %~dp0printer.ps1
```

Файл `printer.ps1`
```
pnputil.exe -i -a "C:\temp\KXDriver2040\64bit\XP and newer\OEMSETUP.inf"
Add-PrinterDriver -Name "Kyocera ECOSYS M2540dn KX"
Add - PrinterPort - Name "IP_[ip-address]" - PrinterHostAddress "[ip-address]"
Add - Printer - Name "[printer_name]" - DriverName "Kyocera ECOSYS M2540dn KX" - PortName "IP_[ip-address]"
```
Как итог - принтер устанавливается в системе, единственное, что я так и не нашел, это как поставить его по умолчанию через cmd.

А для запуска самого первого файла на удаленном хосте, используются следующие ключи `-c -f -h -i` - для копирования файла, запуска и отображения процесса на экране пользователя и `-c -f -h` - просто для копирования и запуска
```
PsExec.exe -u [user] \\[ip-address] -c -f -h -i "install.bat"
```