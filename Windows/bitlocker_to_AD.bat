FOR /F "tokens=*" %%g IN ('c:\windows\system32\manage-bde -protectors -get c: -type recoverypassword ^| findstr "ID: " ') do (SET ID_C=%%g)


set ID_C=%ID_C:ID:=%
c:\windows\system32\manage-bde -protectors -adbackup C: -id %ID_C%



FOR /F "tokens=*" %%h IN ('c:\windows\system32\manage-bde -protectors -get D: -type recoverypassword ^| findstr "ID: " ') do (SET ID_D=%%h)


set ID_D=%ID_D:ID:=%
c:\windows\system32\manage-bde -protectors -adbackup D: -id %ID_D%
