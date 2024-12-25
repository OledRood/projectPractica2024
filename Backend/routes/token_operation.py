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


def get_id_by_token(token):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    cursor.execute('SELECT user_id FROM User where tokens=%s', (token, ))
    user_id = cursor.fetchone()
    close_base(connection=connection, cursor=cursor)
    
    if(user_id == None):
        return False
    return user_id[0]
    
    
