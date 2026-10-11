@echo off
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\subir-sitio.ps1" %*
if errorlevel 1 (
  echo.
  echo ERROR: La operacion ha fallado.
  echo.
  pause
  exit /b 1
)
echo.
pause
