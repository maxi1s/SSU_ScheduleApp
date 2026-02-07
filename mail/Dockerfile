# Dockerfile для mail API сервера
FROM golang:1.24-alpine

# Установка зависимостей
RUN apk add --no-cache git ca-certificates tzdata
ENV TZ=Europe/Saratov

WORKDIR /app

# Копирование файлов модулей и скраппера (контекст = ./mail, scrapper — подпапка)
COPY go.mod go.sum ./
COPY scrapper /app/scrapper
RUN go mod download
RUN cd /app/scrapper && go mod download

# Копирование исходного кода
COPY . .

# Сборка приложения
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o mail .

# Создание директории для данных
RUN mkdir -p /app/data

# Порт для API
EXPOSE 8081

CMD ["./mail"]