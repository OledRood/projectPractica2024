

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


def get_users_list():
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)
    
    cursor.execute("SELECT user_id, username, role FROM User WHERE role != 'Admin'")
    result = cursor.fetchall() 
    close_base(connection=connection, cursor=cursor)
    return result

