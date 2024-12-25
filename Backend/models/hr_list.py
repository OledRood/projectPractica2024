import os
from flask.cli import load_dotenv
import mysql
import mysql.connector

from routes.token_operation import get_id_by_token


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




def get_hr_list(user_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    cursor.execute("SELECT hr_id FROM hr WHERE hr_lead_id = %s", (user_id,))
    hr_list = [hr_id[0] for hr_id in cursor.fetchall()]
    hr_name_list = []
    for hr in hr_list:
        cursor.execute("SELECT username FROM User WHERE user_id = %s", (hr,))
        hr_name_list.append(cursor.fetchone()[0])

    close_base(connection=connection, cursor=cursor)
    # print(hr_name_list)
    return hr_name_list



def isHrlead(user_id, cursor):
    cursor.execute('SELECT role FROM User WHERE user_id = %s', (user_id,))
    result = cursor.fetchone()

    if(result['role'] == 'Hr_lead'):
        return True
    else:
        return False
    
    
def get_lists(token):
    user_id = get_id_by_token(token)
    if(user_id == False):
        return {'vacancy' : 'error'}
    
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)
    result = {}
    if(isHrlead(user_id=user_id, cursor=cursor)):
        result['hr_list'] = get_hr_list(user_id=user_id)
    else: result["hr_list"] = []
    
    cursor.execute('SELECT DISTINCT vacancy, source FROM resume')
    vacancy_source_lists = cursor.fetchall()
    close_base(connection=connection, cursor=cursor)
    
    vacancys = []
    sources = []
    for row in vacancy_source_lists:
        vacancys.append(row['vacancy'])
        sources.append(row['source'])
    

    # Перестраховка, что точно уникальные значения
    result['vacancy'] = list(set(vacancys))
    result['source'] = list(set(sources))
    return result

