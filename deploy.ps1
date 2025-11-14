# Скрипт для развертывания системы расписаний SGU в Docker (PowerShell версия)

Write-Host " Развертывание системы расписаний SGU в Docker" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Проверка наличия Docker и Docker Compose
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Host "Docker и Docker Compose найдены" -ForegroundColor Green
} catch {
    Write-Host "Docker или Docker Compose не установлены!" -ForegroundColor Red
    exit 1
}



# Перемещение папки scrapper в mail
Write-Host "`nПодготовка структуры проекта..." -ForegroundColor Yellow
$scrapperSource = "scrapper"
$scrapperDest = ".\mail\scrapper"

if (Test-Path $scrapperSource) {
    if (Test-Path $scrapperDest) {
        Write-Host "Удаление существующей папки scrapper в mail..." -ForegroundColor Yellow
        Remove-Item -Path $scrapperDest -Recurse -Force
    }
    
    Write-Host "Копирование scrapper в mail..." -ForegroundColor Yellow
    Copy-Item -Path $scrapperSource -Destination $scrapperDest -Recurse -Force
    Write-Host "Папка scrapper успешно скопирована в mail!" -ForegroundColor Green
} else {
    Write-Host "Предупреждение: Папка scrapper не найдена по пути $scrapperSource" -ForegroundColor Yellow
    Write-Host "Продолжение без копирования scrapper..." -ForegroundColor Yellow
}




# Сборка образов
Write-Host "`nСборка Docker образов..." -ForegroundColor Yellow
docker-compose -f docker-compose.full.yml build

# Запуск сервисов
Write-Host "`nЗапуск сервисов..." -ForegroundColor Yellow
docker-compose -f docker-compose.full.yml up -d

# Ожидание готовности PostgreSQL
Write-Host "`nОжидание готовности PostgreSQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Проверка состояния
Write-Host "`nСтатус сервисов:" -ForegroundColor Green
docker-compose -f docker-compose.full.yml ps

# Проверка логов
Write-Host "`nПоследние логи mail сервера:" -ForegroundColor Green
docker logs schedule_mail --tail 20

Write-Host "`nРазвертывание завершено!" -ForegroundColor Green
Write-Host "`nAPI доступен по адресу: http://localhost:8081" -ForegroundColor Cyan
Write-Host "Примеры запросов:" -ForegroundColor Cyan
Write-Host "  curl http://localhost:8081/faculties" -ForegroundColor White
Write-Host "  curl http://localhost:8081/knt/do/411" -ForegroundColor White
Write-Host "`nМониторинг:" -ForegroundColor Cyan
Write-Host "  docker-compose -f docker-compose.full.yml logs -f" -ForegroundColor White
Write-Host "  docker ps" -ForegroundColor White
Write-Host "`nОстановка:" -ForegroundColor Cyan
Write-Host "  docker-compose -f docker-compose.full.yml down" -ForegroundColor White