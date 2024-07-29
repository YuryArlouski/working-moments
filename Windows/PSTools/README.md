# Об автоматизации работы

В начале моей работы в ТехАрт (2019 год) могло быть по 10 выходов новых сотрудников на работы в неделю, кажется что не особо много, но сейчас, смотря на это с середины 2024 года кажется очень много)

В общем, кроме задач по подготовке новых устройств, была также рабочаю рутина по стандартным моментам, такие как - установка новых программ, принтеров и тому подобное.

С этого момента начался процесс по автоматизации части работы. Далее я опишу как это происходило. Часть из всего этого уже не актуально, но такие моменты интересно вспоминать.

Впоследствии все сформировалось в программу на C#, но ниже буду описывать сами скрипты. 

## Подключение к Windows-машинам через cmd

Пусть мой начался со следующего набора программ [PSTools](https://learn.microsoft.com/ru-ru/sysinternals/downloads/pstools), а если быть точнее то с [PsExec](https://learn.microsoft.com/ru-ru/sysinternals/downloads/psexec).

С помощью всего пары ключей можно подключится к другой Windows-машине через cmd или powershell, как кому удобнее:
```bat
PsExec.exe -u [user] -h \\[ip-address] cmd
```
Также так можно удаленно менять пароль на локальной УЗ на удаленном устройстве - `net user Administrator $pass$`, `$pass$` - тут вводите пароль в открытом виде, поэтому такой способ не рекомендую.

## Удаленная установка принтера на устройство
Как я и писал выше, мой экскур начался с установки принтеров на устройства. В моем случае мне повезло, тк принтера был Kyocera и все приблизительно одной модели, так что в результате все сформировалось в пару скриптов.

Первый - скачивает на устройство драйвера и необходимый набор файлов с сетевой шары `install.bat`:
```bat
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
```bat
Powershell.exe -executionpolicy Bypass -File %~dp0printer.ps1
```

Файл `printer.ps1`
```ps1
pnputil.exe -i -a "C:\temp\KXDriver2040\64bit\XP and newer\OEMSETUP.inf"
Add-PrinterDriver -Name "Kyocera ECOSYS M2540dn KX"
Add - PrinterPort - Name "IP_[ip-address]" - PrinterHostAddress "[ip-address]"
Add - Printer - Name "[printer_name]" - DriverName "Kyocera ECOSYS M2540dn KX" - PortName "IP_[ip-address]"
```
Как итог - принтер устанавливается в системе, единственное, что я так и не нашел, это как поставить его по умолчанию через cmd.

А для запуска самого первого файла на удаленном хосте, используются следующие ключи `-c -f -h -i` - для копирования файла, запуска и отображения процесса на экране пользователя и `-c -f -h` - просто для копирования и запуска
```bat
PsExec.exe -u [user] \\[ip-address] -c -f -h -i "install.bat"
```
## Удаленная установка ПО
Практически не отличается от установки драйверов на принтера. Отправляется файл, в котором есть список того, что скачивать на устрйоство и откуда, а далее запуск этих программ.

Единственная разница в том, что не все программы можно поставить в шадоу-моде, поэтому в некоторых программах придется прокликать Next -> Next -> Close.

## Обновление драйверов на ноутбуках

В крупных компаниях обычно закупаются +- одни модели ноутбуков. В моей на то время были HP ProBook 450 g7/8, а тк в пик выходов они готовились пачками, то и ждать обновления драйверов на них даже через HP Support Assistant было долго, из этого у меня возникла мысль немного автоматизировать данный процесс. 

> [!NOTE]
>Данная часть уже писалась на C# и как обычно бывает без комментариев...

Изначально надо было как-то автоматизировать именно скачивание драйверов в одну шаровую папку. Делалось это внося номера обновления в обычный TextBox, а также выбиралась необходимая модель ноутбука, а дальше начиналась магия, которую я прикреплю ниже.

Чтож, кнопка отвечающая за отправление данных дальше на скачивание, делается это в потоках, поэтому и немного тяжело в памяти восстанавливать.
```C#
private void Download_hp_soft_button_Click(object sender, EventArgs e)
        {
            try
            {
                list_drivers_hp.Clear();
                string model = CB_model_laptop.Text;
                list_drivers_hp.AddRange(TB_download_hp.Text.Split(','));
                new Thread(() => download_delegate_link(model)).Start();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
           }
```

Дальше переходим к замудренному способу скачивания.

```C#
void download_delegate_link(string model)
        {
            LB_iteam_delegate lb = new LB_iteam_delegate(LB_add_iteams);
            int num_int = 0;
            int num_first, num_second;
            string link = null;
            FileStream file1 = new FileStream(Application.StartupPath.ToString() + "\\unzip.bat", FileMode.Create);
            StreamWriter fnew1 = new StreamWriter(file1, Encoding.GetEncoding(1251));


            for (int count = 0; count < list_drivers_hp.Count; count++)
            {
                link = "https://ftp.hp.com/pub/softpaq/";
                num_int = Int32.Parse(list_drivers_hp[count]);
                num_first = num_int / 1000;
                num_second = num_int % 1000;
                if (num_second < 501)
                {
                    link += "sp" + num_first + "001-" + num_first + "500/sp" + num_int + ".exe";
                }
                else
                {
                    link += "sp" + num_first + "501-" + (num_first + 1) + "000/sp" + num_int + ".exe";
                }
                download_link(link, model, num_int, lb, fnew1);
            }
            fnew1.Close();
            ProcessStartInfo psi = new ProcessStartInfo(Application.StartupPath.ToString() + "\\unzip.bat");
            psi.UseShellExecute = true;
            psi.Verb = "runas";
            Process.Start(psi);
            LB_log.BeginInvoke(lb, new object[] { "Done" });
        }

        void download_link(string link, string path, int num, LB_iteam_delegate lb, StreamWriter fnew1)
        {
            string url = link;

            using (WebClient client = new WebClient())
            {
                string name = path_link + "\\drivers_laptop\\" + path;
                client.DownloadFile(url, name + "\\sp" + num + ".exe");
                LB_log.BeginInvoke(lb, new object[] { link + " - download" });

                fnew1.WriteLine(name + "\\sp" + num + ".exe /s /e /f " + name + "\\sp" + num);
                fnew1.WriteLine("erase " + name + "\\sp" + num + ".exe");
            }

        }
```

Далее идет формирование списка для обновления и создание bat-файла для обновления.
> [!NOTE]
> Для того, чтобы обновление биоса шло в самом конце, меняю руками название папки

```C#
private void button4_Click(object sender, EventArgs e)
        {
            try
            {
                string dirName = path_link + "\\drivers_laptop\\" + CB_model_laptop.Text;
                FileStream file1 = new FileStream(dirName + @"\install.bat", FileMode.Create);
                StreamWriter fnew1 = new StreamWriter(file1, Encoding.GetEncoding(1251));
                fnew1.WriteLine("@echo off");
                fnew1.WriteLine("mkdir c:\\temp");

                fnew1.WriteLine("c:\\windows\\system32\\xcopy /Y /Z /R /E " + dirName + "\\* c:\\temp\\");

                //LB_log.Items.Add(dirName);
                if (Directory.Exists(dirName))
                {
                    //LB_log.Items.Add("Подкаталоги:");
                    string[] dirs = Directory.GetDirectories(dirName);
                    foreach (string s in dirs)
                    {
                        LB_log.Items.Add(s);
                        string[] collect = s.Split('\\');
                        string[] files = Directory.GetFiles(s);

                        foreach (string sf in files)
                        {
                            string[] collect_f = sf.Split('\\');
                            //LB_files.Items.Add(collect_f[collect_f.Count() - 1]);
                            if (collect_f[collect_f.Count() - 1] == "InstallCmdWrapper.exe")
                            {
                                fnew1.WriteLine(@"C:\temp\" + collect[collect.Count() - 1] + "\\InstallCmdWrapper.exe");
                                LB_files.Items.Add(collect[collect.Count() - 1] + " InstallCmdWrapper.exe");
                            }
                            if (collect_f[collect_f.Count() - 1] == "install.exe" || collect_f[collect_f.Count() - 1] == "Install.exe")
                            {
                                fnew1.WriteLine(@"C:\temp\" + collect[collect.Count() - 1] + "\\install.exe");
                                LB_files.Items.Add(collect[collect.Count() - 1] + " install.exe");
                            }
                            if (collect_f[collect_f.Count() - 1] == "HpFirmwareUpdRec.exe")
                            {
                                fnew1.WriteLine(@"C:\temp\" + collect[collect.Count() - 1] + "\\HpFirmwareUpdRec.exe");
                                LB_files.Items.Add(collect[collect.Count() - 1] + " HpFirmwareUpdRec.exe");
                            }
                            if (collect_f[collect_f.Count() - 1] == "SetupSerialIO.exe")
                            {
                                fnew1.WriteLine(@"C:\temp\" + collect[collect.Count() - 1] + "\\SetupSerialIO.exe -s");
                                LB_files.Items.Add(collect[collect.Count() - 1] + " SetupSerialIO.exe");
                            }
                            //LB_log.Items.Add(sf);
                            //LB_log.Items.Add(collect_f[collect_f.Count() - 1]);
                        }
                    }
                }

                //fnew1.WriteLine("rmdir /S /Q c:\\temp");
                fnew1.WriteLine("exit");
                fnew1.Close();
                LB_add_iteams("bat file update: " + CB_model_laptop.Text);
            }
            catch (Exception ex)
                {
                    MessageBox.Show(ex.ToString());
                }
            }
```

Ну а как отправлять bat-файл на удаленный ПК, я отписывал выше xD

## Небольшие мелочи для управления удаленным устройством

### Добавление пользователя в группу

```cmd
powershell Add-LocalGroupMember -Group \"{0}\" -Member \"{1}\"
```
{0} - локальная группа
{1} - доменная УЗ, можно и доменное имя использовать, но я использую SID.

```ps1
Get-ADUser -Filter \"(Name -like'*"{0}"*')\"
```
{0} - уникальное имя в домене

### Вывод списка пользователей в конкретной группе

```cmd
net localgroup \"{0}\"
```
{0} - локальная группа

### Проверка описания ПК

В компании используется практика указания чье это устройство, его можно увидеть в описании

```cmd
net config server
```

### Изменение описания

```cmd
net config server /srvcomment:\"{0}\"
```
{0} - имя сотрудника / описание для ПК

### Выключение / перезагрузка ПК

```cmd
shutdown -s -f -t 0 # выключение

shutdown -r -f -t 0 # перезагрузка
```
