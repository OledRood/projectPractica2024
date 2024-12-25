
import os
from dotenv import load_dotenv
import mysql.connector


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


def select_all_table(cursor, name_table):
    cursor.execute('SELECT * FROM ' + name_table)
    user_table = cursor.fetchall()
    return user_table


def get_users_tables(token):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)
    result = {"user_table": [], 'hr_table': [], 'hr_table': [], 'resume_table': []}
    # Удалить токены и подумать над реализацией смены пароля на нормальный вида
    result['user_table'] = select_all_table(cursor=cursor, name_table = "User")
    result['hr_table'] = select_all_table(cursor=cursor, name_table = "hr")
    result['hr_lead_table'] = select_all_table(cursor=cursor, name_table = "hr_lead")
    result['resume_table'] = select_all_table(cursor=cursor, name_table = 'resume')
    return result