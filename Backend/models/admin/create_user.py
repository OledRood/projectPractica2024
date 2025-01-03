import hashlib
import os
from dotenv import load_dotenv
import mysql.connector

from routes.token_operation import get_id_by_token

def hash(password):
    md5_hash = hashlib.new('md5')
    md5_hash.update(password.encode())
    print(md5_hash.hexdigest())
    return md5_hash.hexdigest()
    



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


def create_hr(user_id, hr_lead_id, cursor, connection):
    insert_query = "INSERT INTO Hr ( hr_id, hr_lead_id) VALUES (%s, %s)"
    cursor.execute(insert_query, (user_id, hr_lead_id))
    connection.commit()


def create_hr_lead(user_id, cursor, connection):
    insert_query = "INSERT INTO hr_lead (hr_lead_id) VALUES ( %s)"
    cursor.execute(insert_query, (user_id,))
    connection.commit()    

def create_user(username, role, password, connection, cursor):

    cursor.execute("SELECT user_id FROM User WHERE username = %s", (username,))
    user_id = cursor.fetchone();
    if(user_id is not None):    
        return "User has already been created"
    try:
        insert_query = "INSERT INTO User (username, role, password) VALUES (%s, %s, %s)"
        cursor.execute(insert_query, (username, role, hash(password)))
        connection.commit()
        return 'create'
    except:
        return "Something wrong with create base"

def isAdmin(id, cursor):
    cursor.execute("SELECT role FROM User WHERE user_id = %s", (id,))
    role = cursor.fetchone();
    if(role[0] == "Admin"):
        return True
    return False 


def get_hr_lead_id_by_name(hr_lead_name, cursor):

    cursor.execute('SELECT user_id FROM User WHERE username = %s', (hr_lead_name,))
    return cursor.fetchone()[0]

def create_new_user(username, user_role, password, hr_lead_name, token):
    id = get_id_by_token(token)
    if(id ==  False):
        return 'token error'
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    if(not (isAdmin(cursor=cursor, id=id))):
        close_base(connection=connection, cursor=cursor)
        return {'response':"You don't have rights"}

    #Создаем пользователя в базе user
    result_create_user = create_user(username=username, role=user_role, password=password, connection=connection, cursor=cursor)
    # Если какая-то проблема
    if (result_create_user != "create"):
        close_base(cursor, connection)
        print(result_create_user)
        return {'response':"error in create"}

    # получаем user_id
    cursor.execute("SELECT user_id FROM User WHERE username = %s and password = %s", (username, hash(password)))
    user_id = cursor.fetchone()[0];
    
    try:
        if(user_role == "Hr"):
            hr_lead_id = get_hr_lead_id_by_name(hr_lead_name=hr_lead_name, cursor=cursor);
            create_hr(user_id=user_id, hr_lead_id=hr_lead_id, cursor=cursor, connection=connection);
            print('Hr is created')
        elif(user_role == "Hr_lead"):
            create_hr_lead(user_id=user_id, cursor=cursor, connection=connection)
            print('Hr_lead is created')
    except :
        close_base(cursor, connection);
        return {'response': "Error with create user in " + user_role + ' table'}
    close_base(cursor, connection);
    return {'response':"Data is recorded"}





