# Об автоматизации работы

В начале моей работы в ТехАрт (2019 год) могло быть по 10 выходов новых сотрудников на работы в неделю, кажется что не особо много, но сейчас, смотря на это с середины 2024 года кажется очень много)

В общем, кроме задач по подготовке новых устройств, была также рабочаю рутина по стандартным моментам, такие как - установка новых программ, принтеров и тому подобное.

С этого момента начался процесс по автоматизации части работы. Далее я опишу как это происходило. Часть из всего этого уже не актуально, но такие моменты интересно вспоминать.

Впоследствии все сформировалось в программу на C#, но сами способы автоматизации перенес в [отдельный раздел](https://github.com/YuryArlouski/working-moments/tree/main/Windows/PSTools)


# О Bitlocker

В начале моей работы в ТехАрт начался переход на "практику с использованием TPM", довольно полезная практика скажу я Вам, не без своих минусов конечно. На тот моент, как и сейчас windows-устройства раскатывались с помощью WDS, но бывают случаи, когда BitLocker автоматически не хочет заводится, а в следствии этого не синхронизирует ключи с AD, на помощь пришел данный скрипт, написанный моим коллегой.

Запускаем от имени администратора и смотрим, чтобы не было сообщений типа Error и недостаточно прав.

[bitlocker_to_AD.bat](https://github.com/YuryArlouski/working-moments/blob/main/Windows/bitlocker_to_AD.bat)


# Исправление турбо-буста устройств

Как-то пришел сотрудник с ноутом в ноябре 2023 года, с проблемой, что тротлит и греется ноутбук.

На тот момент для меня такое поведение было в новинку, но глянув в Диспетчер задач увидел, что проблема в том, что CPU работает в турбо-режиме.

Гуглинг привел меня вот на такую статью от апреля 2022: https://club.dns-shop.ru/discussions/t-89-noutbuki/278451-otkluchaem-turbobust-samyii-prostoi-i-nadejnyii-sposob/

Решение простое, изменение реестра и исправление параметров в настройках электропитания.

На одном/двух устрйоствах руками не сложно это исправлять, но приблизительно в это же время, в компании начался ребрендинг и в следствии перевод в новый домен и конечно же такие устрйоства я начал встречать все боьше и больше, из это я решил найти, где в реестре хранятся параметры, управляющие "Aggressive mode" - из этого вышел данный файл - [minus_agressive_mode.reg](https://github.com/YuryArlouski/working-moments/blob/main/Windows/minus_agressive_mode.reg) - запустить и перезагрузить устрйоство, впринципе все =)
