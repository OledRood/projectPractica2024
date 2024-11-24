from flask import json
from sqlalchemy import create_engine, MetaData, Table, select
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# Загружаем переменные окружения
load_dotenv()

# Конфигурация базы данных
db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': 'hrmonitor'
}

# Формируем строку подключения
db_url = (
    f"mysql+pymysql://{db_config['user']}:{db_config['password']}@"
    f"{db_config['host']}/{db_config['database']}"
)

# Создаем подключение
engine = create_engine(db_url, echo=True)

# Подключаемся к таблице через MetaData
metadata = MetaData()
resume_table = Table('resume', metadata, autoload_with=engine)

# Создаем фабрику сессий
Session = sessionmaker(bind=engine)

# Выполняем запрос SELECT * FROM resume
with engine.connect() as conn:
    query = select(resume_table)  # Создаем SQL-запрос
    results = conn.execute(query)  # Выполняем запрос
    
    # Преобразуем результат в список словарей
    data = [dict(row._mapping) for row in results]
    
    # Конвертируем в JSON
    json_data = json.dumps(data, ensure_ascii=False, indent=4)
    
    # Печатаем JSON
    print(json_data)