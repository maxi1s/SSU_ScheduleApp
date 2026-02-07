@echo off
chcp 65001 >nul
setlocal

echo.
echo  Развертывание системы расписаний SGU в Docker
echo ================================================
echo.

REM Проверка Docker
where docker >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Docker не найден. Установите Docker Desktop и запустите его.
    exit /b 1
)

REM Docker Compose v2: docker compose (без дефиса)
docker compose version >nul 2>nul
if errorlevel 1 (
    docker-compose version >nul 2>nul
    if errorlevel 1 (
        echo [ОШИБКА] Docker Compose не найден.
        exit /b 1
    )
    set COMPOSE_CMD=docker-compose
) else (
    set COMPOSE_CMD=docker compose
)

echo [OK] Docker найден.
echo.

REM Переход в каталог скрипта (работает при запуске откуда угодно)
cd /d "%~dp0"

echo Сборка образов...
%COMPOSE_CMD% -f docker-compose.full.yml build
if errorlevel 1 (
    echo [ОШИБКА] Сборка не удалась.
    exit /b 1
)

echo.
echo Запуск сервисов...
%COMPOSE_CMD% -f docker-compose.full.yml up -d
if errorlevel 1 (
    echo [ОШИБКА] Запуск не удался.
    exit /b 1
)

echo.
echo Ожидание готовности (5 сек)...
timeout /t 5 /nobreak >nul

echo.
echo Статус контейнеров:
%COMPOSE_CMD% -f docker-compose.full.yml ps

echo.
echo Последние логи mail:
docker logs schedule_mail --tail 20 2>nul

echo.
echo ================================================
echo  Развертывание завершено.
echo  API: http://localhost:8081
echo  Логи: %COMPOSE_CMD% -f docker-compose.full.yml logs -f
echo  Остановка: %COMPOSE_CMD% -f docker-compose.full.yml down
echo ================================================
echo.
pause
endlocal
exit /b 0
