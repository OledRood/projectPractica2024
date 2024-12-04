import hashlib
import os
from dotenv import load_dotenv
import mysql.connector

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
    print(role[0])
    if(role[0] == "Admin"):
        return True
    return False 





def create_new_user(username, role, password, hr_lead_id, id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    if(not (isAdmin(cursor=cursor, id=id))):
        return "You don't have rights"

    #Создаем пользователя в базе user
    result_create_user = create_user(username=username, role=role, password=password, connection=connection, cursor=cursor)
    # Если какая-то проблема
    if (result_create_user != "create"):
        close_base(cursor, connection)
        return result_create_user

    # получаем user_id
    cursor.execute("SELECT user_id FROM User WHERE username = %s and password = %s", (username, hash(password)))
    user_id = cursor.fetchone()[0];
    
    # try:
    if(role == "Hr"):
        create_hr(user_id=user_id, hr_lead_id=hr_lead_id, cursor=cursor, connection=connection);
        print('Hr is created')
    elif(role == "Hr_lead"):
        create_hr_lead(user_id=user_id, cursor=cursor, connection=connection)
        print('Hr_lead is created')
    # except :
    #     close_base(cursor, connection);
    #     return "Error with create user in " + role + ' table'  
    close_base(cursor, connection);
    return "Data is recorded"





