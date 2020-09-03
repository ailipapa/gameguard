@echo off
title install

rem #### SET RUNNING AS ADMIN
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit

rem #### START
setlocal enabledelayedexpansion

rem #### COPY FILE TO SYSTEM FOLDER
cd /d %~dp0
copy gameguard.bat C:\Windows\System32\

rem #### IMPORT SCHEDULE TASK
set taskname=gameguard
set filename=gameguard.xml
schtasks /create /tn %taskname% /xml %filename%

pause
