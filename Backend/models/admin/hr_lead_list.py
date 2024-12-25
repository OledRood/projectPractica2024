# import hashlib
import os
from dotenv import load_dotenv
import mysql.connector


from models.token_operation import get_id_by_token



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


def isAdmin(id, cursor):
    cursor.execute("SELECT role FROM User WHERE user_id = %s", (id,))
    role = cursor.fetchone();
    print(role[0])
    if(role[0] == "Admin"):
        return True
    return False 

def get_hr_lead_list(token):
    user_id = get_id_by_token(token)
    if(user_id == False ):
        return {'response' : 'token error'}
    
    
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    if(not (isAdmin(cursor=cursor, id=user_id))):
        close_base(connection=connection, cursor=cursor)
        return {'response':"You don't have rights"}

    query = "SELECT username FROM User WHERE role = 'Hr_lead'"
    cursor.execute(query)
    
    hr_lead_list = cursor.fetchall()
    formatted_list = [row[0] for row in hr_lead_list]

    close_base(cursor=cursor, connection=connection)
    return {'response' : 'good', 'data' : formatted_list}

