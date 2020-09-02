@echo off
title game guard

rem #### START
setlocal enabledelayedexpansion

rem **** running program name
::SET PROG EXE AND NAME 
set prog=WeChat.exe
set game=KING HONOR

rem **** second
set TIME_OUT=1
set /a TIME_LIMITED=60*30
set /a TIME_REST=60*60*2
set run_time=0
set rest_time=0

rem **** run flag
set run_flag=0

rem **** config
set COUNT_LIMITED=3
set CONFIG_FILE=config.txt
set config_date=0
set config_count=0


rem **** write config to file
if not exist %CONFIG_FILE% (
	echo %date%:%config_count%>%CONFIG_FILE%
)

rem **** read config from file
for /f "tokens=1 delims=:" %%i in (%CONFIG_FILE%) do (
	set config_date=%%i
	echo config_date:!config_date!
)
for /f "tokens=2 delims=:" %%i in (%CONFIG_FILE%) do (
	set config_count=%%i
	echo config_count:!config_count!
)

rem **** check run flag
if !config_count! lss %COUNT_LIMITED% (
	set run_flag=1
)


rem **** main loop
:loop

rem **** check the prog whether is running
tasklist | findstr /i %prog% >NUL
if errorlevel 1 (
	rem **** detect prog is not running

	rem **** date config has changed
	if "%date%" neq "!config_date!" (
		rem **** reset config date and count
		set config_date=%date%
		set config_count=0
		echo !config_date!:!config_count!>%CONFIG_FILE%
		echo current date:%date%	last date:!config_date!
		rem **** reset flag
		set run_flag=1
		set run_time=0
		echo run_time has been reset, you can play again.
	)
	
	rem **** todo rest time count when run_flag=0 and count < COUNT_LIMITED
	if !run_flag! equ 0 (
		if !config_count! lss %COUNT_LIMITED% (
			rem **** rest time is over
			if !rest_time! geq %TIME_REST% (
				rem **** reset flag
				set run_flag=1
				set run_time=0
				echo run_time has been reset, you can play again.
			) ^
			else (
				rem **** count rest time
				set /a rest_time+=%TIME_OUT%
				echo %prog% is rest !rest_time!s
			)
		)
	)

	rem **** waiting timeout
	timeout /t %TIME_OUT% /nobreak >NUL
) ^
else (
	rem **** detect prog is running

	rem **** check run flag
	if !run_flag! equ 1 (
		set /a run_time+=%TIME_OUT%
		echo %prog% is running !run_time!s
		
		rem **** prog is out of time and must to be killed
		if !run_time! geq %TIME_LIMITED% (
			rem **** update config conunt
			set /a config_count+=1
			echo !config_date!:!config_count!>%CONFIG_FILE%

			rem **** reset run flag
			set run_flag=0
			set run_time=0
			set rest_time=0
		)
	) ^
	else (
		rem **** kill the prog
		taskkill /f /im %prog%
		echo %prog% is killed

		rem **** show warning
		if !config_count! lss %COUNT_LIMITED% (
			rem **** prog is in limited count
			set /a run_mins=%TIME_LIMITED%/60
			set /a rest_mins=%TIME_REST%/60-!rest_time!/60
			echo msgbox "YOU HAVE PLAYED %game% !run_mins! MINUTES, PLEASE TAKE A BREAK AND TRY AGAIN !rest_mins! MINUTES LATER.",64,"WARNING">%temp%\alert.vbs && start %temp%\alert.vbs && timeout /t 5 /nobreak >NUL && del %temp%\alert.vbs
		) ^
		else (
			rem **** prog is over the limited count
			echo msgbox "YOU HAVE EXCEEDED THE TIME LIMIT, PLEASE PLAY TOMORROW.",64,"WARNING">%temp%\alert.vbs && start %temp%\alert.vbs && timeout /t 5 /nobreak >NUL && del %temp%\alert.vbs
		)
	)
	
	rem **** waiting timeout
	timeout /t %TIME_OUT% /nobreak >NUL
)

goto loop


EQU，等于
NEQ，不等于
LSS，小于
LEQ，小于等于
GTR，大于
GEQ，大于或等于

set /p config_date=<%CONFIG_FILE%

mshta vbscript:msgbox("MESSAGE",64,"TITLE")(window.close)
msg %username% /time:10 "SHOW MESSAGE"
mshta vbscript:msgbox("YOU HAVE PLAYED %game% !run_mins! MINUTES, YOU MUST TAKE A BREAK.",64,"WARNING")(window.close)
echo msgbox "YOU HAVE PLAYED %game% !run_mins! MINUTES, YOU MUST TAKE A BREAK.",64,"WARNING">%temp%\alert.vbs && start %temp%\alert.vbs && timeout /t 2 /nobreak >NUL && del %temp%\alert.vbs
msg %username% /time 15 "YOU HAVE PLAYED %game% !run_mins! MINUTES, YOU MUST TAKE A BREAK."



rem #### SET RUNNING AS ADMIN
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit


>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )


rem #### SET RUNNING IN BACKGROUND
if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit
:begin

