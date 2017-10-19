REM Oct 23 2016	Initial Implementation - Ashish Gupta
REM Source: Maximum PC November 2016

REM This batch file creates a "guest" user called "visitor".
REM It must be run in an administrator window.

net user visitor /add /active:yes
net user visitor *

REM Press <ENTER> twice when prompted for a password
REM in order to create a blank password.

net localgroup users visitor /delete
net localgroup guests visitor /add