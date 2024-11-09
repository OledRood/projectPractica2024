from datetime import datetime 
import mysql.connector
import os
from dotenv import load_dotenv
#  конвертировать строку обратоно в дату
# dt_object = datetime.strptime(dt_string, "%d/%m/%Y %H:%M:%S")

load_dotenv()
db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': 'hrmonitor'
}

def close_base(cursor, connection):
    cursor.close()
    connection.close()



status_of_resume = {0: "Открыта", 1: "Изучена", 2: "Интервью", 3: "Прошли интервью", 4: "Техническое собеседование", 5: "Пройдено техническое собеседование", 6: "Оффер"}


def create(vacancy, age, source, hr_user_id, name ):
    archiv = 0;
    status = status_of_resume[0]
    date_last_changes = datetime.now()
    age = int(age)
    hr_user_id = int(hr_user_id)
    
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    cursor.execute("SELECT hr_id FROM hr WHERE user_id= %s", (hr_user_id,))
    hr_id = cursor.fetchone()[0]
    
    insert_query = "INSERT INTO resume (name, vacancy, age, status, date_last_changes, source, hr_id, archiv)  VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
    cursor.execute(insert_query, (name, vacancy, age, status, date_last_changes, source, hr_id, archiv))
    connection.commit()
    close_base(connection=connection, cursor=cursor)
    
    
    

