@echo off

setlocal

:: Configurable Version Variables
for /f "tokens=1,* delims==" %%a in (config.txt) do set %%a=%%b

:: Check Docker
call docker -v >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker is not installed.
) else (
    echo [OK] Docker is installed.
)

echo.

:: Check Docker Compose
call docker-compose -v >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker Compose is not installed.
) else (
    echo [OK] Docker Compose is installed.
)

echo.

:: Check Java and Java Class Version
echo public class TempClass {^
public static void main(String[] args) {^
double version = Double.parseDouble(System.getProperty("java.class.version"));^
System.out.print((int) version);^
}^
} > TempClass.java

call javap -version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Java is not installed.
) else (
    echo [OK] Java is installed.
    setlocal enabledelayedexpansion
    for /f "tokens=1" %%a in ('javap -version 2^>^&1') do set JAVA_VERSION=%%a
    for /f "tokens=1,2 delims=." %%x in ("!JAVA_VERSION!") do (
        if %%x LSS %JAVA_VERSION_MIN% (
            echo [FAIL] Java version !JAVA_VERSION! is below the minimum required ^(%JAVA_VERSION_MIN%^).
        ) else if %%x GTR %JAVA_VERSION_MAX% (
            echo [FAIL] Java version !JAVA_VERSION! is above the maximum allowed ^(%JAVA_VERSION_MAX%^).
        ) else (
            echo [OK] Java version !JAVA_VERSION! is within the acceptable range ^(%JAVA_VERSION_MIN% - %JAVA_VERSION_MAX%^).
        )
    )

    call javac TempClass.java
    FOR /F %%i IN ('java TempClass') DO SET CLASS_VERSION=%%i
    del TempClass.class

    if defined CLASS_VERSION (
        if !CLASS_VERSION! lss %JAVA_CLASS_VERSION_MIN% (
            echo [FAIL] Java Class version !CLASS_VERSION! is below the minimum required ^(%JAVA_CLASS_VERSION_MIN%^).
        ) else if !CLASS_VERSION! gtr %JAVA_CLASS_VERSION_MAX% (
            echo [FAIL] Java Class version !CLASS_VERSION! is above the maximum allowed ^(%JAVA_CLASS_VERSION_MAX%^).
        ) else (
            echo [OK] Java Class version !CLASS_VERSION! is within the acceptable range ^(%JAVA_CLASS_VERSION_MIN% - %JAVA_CLASS_VERSION_MAX%^).
        )
    ) else (
        echo [WARN] Failed to determine Java Class Version.
    )
)
del TempClass.java

echo.

:: Check Git
call git --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Git is not installed.
) else (
    echo [OK] Git is installed.
)

endlocal