@echo off
setlocal
set "MAVEN_HOME=%~dp0tools\apache-maven-3.9.16"
"%MAVEN_HOME%\bin\mvn.cmd" %*
