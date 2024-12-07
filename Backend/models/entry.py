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
    
    records = [(1, 'Oleg', 'Admin', '1234'),
                (9, 'Natalia Sergeevna', 'Hr', '829df59939263352dc5355b565d28929'),
                (10, 'admin', 'Admin', '21232f297a57a5a743894a0e4a801fc3'),
                (11, 'Евегений Викторович', 'Hr_lead', '1883787243611315520'),
                (19, 'Владимир Гавриков', 'Hr', '6852131287138639844'),
                (20, 'Анастасия Сергеевна', 'Hr_lead', '7475651007808548847'),
                (35, 'hr_lead', 'Hr_lead', 'e51f7195f93ee0f6377f0acbeba9ffd7'),
                (36, 'hr', 'Hr', 'adab7b701f23bb82014c8506d3dc784e'),
                (38, 'Иванов Иван Иванович', 'Hr', '3fc0a7acf087f549ac2b266baf94b8b1'),
                (39, 'Потапов Никита Денисович', 'Hr_lead', 'e242f36f4f95f12966da8fa2efd59992'),
                (40, 'Клюшка Лариса Борисовна', 'Hr', '81dc9bdb52d04dc20036dbd8313ed055')]
    update_query = """
UPDATE User
SET username = %s, role = %s, password = %s
WHERE user_id = %s
"""
    for record in records:
        cursor.execute(update_query, (*record[1:], record[0]))  # Обновление записи по resume_id
        connection.commit()
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

  