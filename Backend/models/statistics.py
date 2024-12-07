
# Дает нам статистику по статусу (одного hr)
import os
from dotenv import load_dotenv
import mysql

from models.resume import get_hr_list

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

def func_get_count_element(elements_list):
    set_list = set(elements_list)
    result = {}
    
    for key in set_list:
        result[key] = 0
        for value in elements_list:
            if(value == key): 
                result[key] += 1
                
    return result
    

# Получаем среднее время в каждом статусе для одного hr(по списку его резюме)
#------------------------------------------------------------------------------------------- 
def get_average(list):
    if(list != []):
            
        list.sort()
        seconds = [(list[i + 1] - list[i]).total_seconds() for i in range(len(list) - 1)]
        seconds = sum(seconds) / len(list)
        
        days = seconds // (24 * 3600)  
        seconds %= (24 * 3600)  
        hours = seconds // 3600  
        seconds %= 3600  
        minutes = seconds // 60  
        seconds %= 60  
        return {'days' : int(days), 'hours' : int(hours), 'minutes': int(minutes), "seconds": int(seconds)}

    else:
        return {'days' : 0, 'hours' : 0, 'minutes': 0, "seconds": 0}


def get_average_time_resume(resume_id_list):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)
    list_of_list_datetime = {"Открыто": [] , "Изучено" : [],"Интервью" : [], "Прошли интервью": [], "Техническое собеседование" : [], "Пройдено техническое собеседование" : [], "Оффер" : []}
    query = '''SELECT * FROM status_change_logs'''
    cursor.execute(query)
    table = cursor.fetchall()
    close_base(connection=connection, cursor=cursor)
    # Получаем список всех временных меток для каждого статуса
    for id in resume_id_list:
        for row in table:
            if(row['resume_id'] == id) and (row['old_status'] is not None):
                list_of_list_datetime[row["old_status"]].append(row['change_date'])
                
    average_list = {}       
        
 
    average_list['Открыто'] = get_average(list_of_list_datetime['Открыто'])
    average_list['Изучено'] = get_average(list_of_list_datetime['Изучено'])
    average_list['Интервью'] = get_average(list_of_list_datetime['Интервью'])
    average_list['Прошли интервью'] = get_average(list_of_list_datetime['Прошли интервью'])
    average_list['Техническое собеседование'] = get_average(list_of_list_datetime['Техническое собеседование'])
    average_list['Пройдено техническое собеседование'] = get_average(list_of_list_datetime['Пройдено техническое собеседование'])
    average_list['Оффер'] = get_average(list_of_list_datetime['Оффер'])
        
    return average_list
 

# - Среднее количество кандидатов на позицию 
#-------------------------------------------------------------------------------------------
def get_vacancy_stat(resume_id_list):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    position_list = []
    for resume_id in resume_id_list:
        query = '''SELECT vacancy FROM resume WHERE resume_id = %s'''
        cursor.execute(query, (resume_id,))
        position_list.append(cursor.fetchone()[0])
            
    close_base(connection=connection, cursor=cursor)
    # {'Водитель' : 2}
    print(position_list)
    return func_get_count_element(position_list)

# Получаем колчичесвто резюме каждого статуса у одного hr
#-------------------------------------------------------------------------------------------
def get_status_stat_count(resume_id_list):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    status_list = []
    for resume_id in resume_id_list:
        query = '''SELECT status FROM resume WHERE resume_id = %s'''
        cursor.execute(query, (resume_id,))
        status_list.append(cursor.fetchone()[0])
    close_base(connection=connection, cursor=cursor)
    status_list_keys = ["Открыто", "Изучено","Интервью" , "Прошли интервью", "Техническое собеседование", "Пройдено техническое собеседование" , "Оффер"]
    count_list_status = func_get_count_element(status_list)
    
    for status_key in status_list_keys:
        if not (status_key in count_list_status):
            count_list_status[status_key] = 0

    return count_list_status

# Получаем количество резюме по источникам 
#-------------------------------------------------------------------------------------------
def get_source_stat(resume_id_list):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    source_list = []
    for resume_id in resume_id_list:
        query = '''SELECT source FROM resume WHERE resume_id = %s'''
        cursor.execute(query, (resume_id,))
        source_list.append(cursor.fetchone()[0])
    close_base(connection=connection, cursor=cursor)
    return func_get_count_element(source_list)



# Здесь получаем цельную статистику по user
#-------------------------------------------------------------------------------------------  

def get_name_hr(user_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    query = '''SELECT username FROM User WHERE user_id = %s'''
    cursor.execute(query, (user_id,))
    name = cursor.fetchone()[0]
    return name
    
# Здесь получаем цельную статистику по user
#-------------------------------------------------------------------------------------------    
def get_resume_statistic(user_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    hr_list = get_hr_list(user_id=user_id)
    result_statistic = {}
    count = 0
    for hr_id in hr_list:
        cursor.execute("SELECT resume_id FROM resume WHERE hr_id = %s", (hr_id,))
        resume_id_list = cursor.fetchall()
        resume_id_list = [id[0] for id in resume_id_list]
        source_statistic = get_source_stat(resume_id_list)
        status_statistic = get_status_stat_count(resume_id_list)
        average_time_status = get_average_time_resume(resume_id_list);
        vacancy_statistic = get_vacancy_stat(resume_id_list)
        name_hr = get_name_hr(hr_id)
        result_hr = {"name" : name_hr, "source" : source_statistic, 'status': status_statistic, "average_time_status": average_time_status, 'vacancy': vacancy_statistic}
        result_statistic[count] = result_hr
        count += 1
    close_base(connection=connection, cursor=cursor)

    return result_statistic

            




