import mysql.connector
import os
import uuid
import hashlib

from dotenv import load_dotenv

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


def generate_token():
    return str(uuid.uuid4())
def hash(password):
    md5_hash = hashlib.new('md5')
    md5_hash.update(password.encode())
    print(md5_hash.hexdigest())
    return md5_hash.hexdigest()
    

  

def login(name, password):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    hash_password = hash(password)
    cursor.execute("SELECT user_id FROM User WHERE username = %s and password = %s", (name, hash_password))
    id = cursor.fetchone()
    cursor.execute("SELECT role FROM User WHERE username = %s and password = %s", (name, hash_password))
    role = cursor.fetchone()
    



    if(id is None):
        close_base(connection=connection, cursor=cursor)
        return {"result" : False, "token" : "", "role": ""}
    
    resultId = id[0]
    resultRole = role[0]
    
    token = generate_token()
    cursor.execute('UPDATE User set tokens = %s where user_id = %s', (token, resultId,))
    connection.commit()
    close_base(cursor, connection)
    return {"result" : True, "token" : token, "role": resultRole}

  