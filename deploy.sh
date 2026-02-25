#!/usr/bin/env bash

set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
    exit 1
fi

if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    exit 1
fi


echo "Сборка образов"
$COMPOSE_CMD -f docker-compose.full.yml build

echo
echo "Запуск сервисов"
$COMPOSE_CMD -f docker-compose.full.yml up -d

sleep 5

echo
$COMPOSE_CMD -f docker-compose.full.yml ps

echo
echo "Последние логи mail:"
docker logs schedule_mail --tail 20 2>/dev/null || true

echo
echo "Развертывание завершено"
echo "API: http://localhost:8081"
echo "Логи: $COMPOSE_CMD -f docker-compose.full.yml logs -f"
echo "Остановка: $COMPOSE_CMD -f docker-compose.full.yml down"
echo