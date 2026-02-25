
echo.
echo  Развертывание системы расписаний SGU в Docker
echo ================================================
echo.

where docker >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Docker не найден. Установите Docker Desktop и запустите его.
    popd
    pause
    exit /b 1
)

docker compose version >nul 2>nul
if errorlevel 1 (
    docker-compose version >nul 2>nul
    if errorlevel 1 (
        echo [ОШИБКА] Docker Compose не найден.
        popd
        pause
        exit /b 1
    )
    set "COMPOSE_CMD=docker-compose"
) else (
    set "COMPOSE_CMD=docker compose"
)

echo [OK] Docker найден.
echo.

echo Сборка образов...
%COMPOSE_CMD% -f docker-compose.full.yml build
if errorlevel 1 (
    echo [ОШИБКА] Сборка не удалась.
    popd
    pause
    exit /b 1
)

echo.
echo Запуск сервисов...
%COMPOSE_CMD% -f docker-compose.full.yml up -d
if errorlevel 1 (
    echo [ОШИБКА] Запуск не удался.
    popd
    pause
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

popd
pause
endlocal
exit /b 0
