@echo off
title Moon Engine Setup - WARNING!

color 0E

echo *********************
echo *** [! WARNING !] ***
echo *********************
echo.

echo Before continuing, make sure you have the latest Haxe version and Git installed!
echo In case you aren't sure, you can always download both from Moon Engine's Github!
echo When ready, press any key to proceed.

pause >nul

title Moon Engine Setup - Installing libraries
cls
color 09
echo ***************************************
echo *** Installing Main Dependencies... ***
echo ***************************************
echo.

haxelib install flixel 6.0.0

haxelib install lime 8.2.2

haxelib install openfl 9.4.1

haxelib install flixel-addons 3.3.0

haxelib install flixel-tools 1.5.1

haxelib install flixel-text-input 2.0.2

haxelib install hxcpp-debugger 
haxelib install hxcpp-debug-server 1.2.4
haxelib install hxp

haxelib install moonchart 0.5.0
haxelib install hxvlc 2.1.4
haxelib install hscript-iris
haxelib install flixel-waveform

haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel

haxelib git haxeui-core https://github.com/haxeui/haxeui-core

haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git flxanimate https://github.com/FunkinCrew/flxanimate
haxelib git funkin.visfix https://github.com/toffeecaramel/funkVis-GrigFIX

haxelib set flixel 6.0.0
haxelib set lime 8.2.2
haxelib set openfl 9.4.1
haxelib set flixel-addons 3.3.0
haxelib set flixel-tools 1.5.1
haxelib set flixel-text-input 2.0.2
haxelib set hxcpp-debug-server 1.2.4
haxelib set moonchart 0.5.0
haxelib set hxvlc 2.1.4
haxelib set haxeui-flixel git
haxelib set haxeui-core git
haxelib run lime setup

cls
title Moon Engine Setup - Doing a set-up

echo ****************************************
echo *** You will now set-up your Flixel. ***
echo ****************************************

haxelib run flixel-tools setup
cls

goto InstallVSCReq

:InstallVSCReq
cls
title Moon Engine Setup - WARNING!

color 0E
echo *********************
echo *** [! WARNING !] ***
echo *********************
echo.

echo Would you like to install Visual Studio Community and components?
set /p menu="(NECESSARY TO COMPILE! / 5.5GB) [Y/N] > "
       if %menu%==Y goto InstallVSC
       if %menu%==y goto InstallVSC
       if %menu%==N goto CompleteInstallation
       if %menu%==n goto CompleteInstallation
       cls

:InstallVSC
color 09
title Moon Engine Setup - Installing Visual Studio Community
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe
goto CompleteInstallation

:CompleteInstallation
cls
title Moon Engine Setup - Success
color 0A
echo ***************************************************
echo *** You may now exit. (Press any Key or close.) ***
echo ***************************************************
echo.
pause >nul
exit
