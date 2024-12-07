import os
import mysql
import mysql.connector
from datetime import datetime
from dotenv import load_dotenv





load_dotenv()
db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': 'hrmonitor'
}

status = ['', "Открыто", "Изучено", "Интервью","Прошли интервью", "Техническое собеседование", "Пройдено техническое собеседование", "Оффер"]
def close_base(cursor, connection):
    cursor.close()
    connection.close()
  
#  if old_status and status.index(old_status) > status.index(new_status):
#             for i in range(status.index(old_status), (status.index(new_status) + 1)):
#                 if(i == status.index(new_status)):
#                     break
#                 date_change = datetime.now()
#                 current_old_status = status[i]
#                 next_new_status = status[i + 1]
#                 log_query = """
#                 INSERT INTO status_change_logs (resume_id, old_status, new_status, change_date)
#                 VALUES (%s, %s, %s, %s)
#                             """
#                 cursor.execute(log_query, (resume_id, current_old_status, next_new_status, date_change))
#                 connection.commit()
#             old_status = current_old_status 
  
# def add_logs(resume_id, new_status):
#     print('add_logs')
#     print('resume_id = ', resume_id)
#     try:
#         connection = mysql.connector.connect(**db_config)
#         cursor = connection.cursor(dictionary=True)
#         if(new_status == "Открыта"):
#             old_status = ""
#         else: 
#             select_query = "SELECT status FROM resume WHERE resume_id = %s"
#             cursor.execute(select_query, (resume_id,))
#             old_status = cursor.fetchone()['status']
#             close_base(connection=connection, cursor=cursor)
#         stage = status.index(new_status) - status.index(old_status)
#         if(stage == 0):
#             for i in range(stage): 
#                 print()
#                 index_old_status =  status.index(old_status) + i
#                 print(index_old_status)
#                 update_logs(resume_id=resume_id, index_old_status= index_old_status)
#     except Exception as e:
#         raise Exception("Ошбика в логах: ", e)        
    
    
def add_logs(resume_id, new_status):
    print(f"Вызов add_logs: resume_id = {resume_id}, new_status = {new_status}")
    if resume_id is None:
        raise ValueError("resume_id не может быть None")
    # try:
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)

    if new_status == "Открыто":
        old_status = ""
    else:
        select_query = "SELECT status FROM resume WHERE resume_id = %s"
        cursor.execute(select_query, (resume_id,))
        result = cursor.fetchone()
        if result is None:
            raise ValueError(f"Резюме с resume_id = {resume_id} не найдено")
        old_status = result['status']

    stage = status.index(new_status) - status.index(old_status)
    if stage > 0:
        for i in range(stage):
            index_old_status = status.index(old_status) + i
            print(f"Итерация: index_old_status = {index_old_status}")
            update_logs(resume_id=resume_id, index_old_status=index_old_status)
    close_base(connection=connection, cursor=cursor)
    # except Exception as e:
    #     print(f"Ошибка в add_logs: {e}")
    #     raise    
    
    
def update_logs(resume_id, index_old_status):
    print()
    connection = mysql.connector.connect(**db_config)
    # Для того, чтобы возвращались данные в виде словаря
    cursor = connection.cursor(dictionary=True)
    try:
        if(index_old_status == 0):
            old_status = None
        else: 
            old_status = status[index_old_status]
        new_status = status[index_old_status + 1]
        date_change = datetime.now()     
        log_query = """
                INSERT INTO status_change_logs (resume_id, old_status, new_status, change_date)
                VALUES (%s, %s, %s, %s)  
            """
        cursor.execute(log_query, (resume_id, old_status, new_status, date_change))
        connection.commit()
        close_base(connection=connection, cursor=cursor)    
    except Exception as e:
        close_base(connection=connection, cursor=cursor)
        print(f"Ошибка: {e}")


