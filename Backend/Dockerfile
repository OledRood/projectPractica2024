# # Используем официальный образ Python
# FROM python:3.9-slim

# # Устанавливаем рабочую директорию
# WORKDIR /app

# # Копируем файлы зависимостей
# COPY requirements.txt .

# # Устанавливаем зависимости
# RUN pip install --no-cache-dir -r requirements.txt

# # Копируем весь код
# COPY . .

# # Открываем порт 8080
# EXPOSE 8080

# # Переменная окружения для Flask
# ENV FLASK_APP=main.py

# # Команда для запуска Flask на порте 8080
# CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]

# Добавить в таблицу поле tockens
# ALTER TABLE User
# ADD COLUMN tokens VARCHAR(512) NULL;