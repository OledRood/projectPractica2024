import mysql.connector
import os
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



def hash(password):
    md5_hash = hashlib.new('md5')
    md5_hash.update(password.encode())
    print(md5_hash.hexdigest())
    return md5_hash.hexdigest()
    

  

def login(name, password):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    hash_password = hash(password)
# sqlAlchimya
# connectionKit
    cursor.execute("SELECT user_id FROM User WHERE username = %s and password = %s", (name, hash_password))
    id = cursor.fetchone()
    cursor.execute("SELECT role FROM User WHERE username = %s and password = %s", (name, hash_password))
    role = cursor.fetchone()
    close_base(cursor, connection)


    if(id is None):
        return {"result" : False, "id" : "", "role": ""}
    resultId = id[0]
    resultRole = role[0]
    return {"result" : True, "id" : resultId, "role": resultRole}

  