import os
from flask.cli import load_dotenv
import mysql


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




def get_ht_list(user_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    cursor.execute("SELECT hr_id FROM hr WHERE hr_lead_id = %s", (user_id,))
    hr_list = [hr_id[0] for hr_id in cursor.fetchall()]
    hr_name_list = []
    for hr in hr_list:
        cursor.execute("SELECT username FROM user WHERE user_id = %s", (hr,))
        hr_name_list.append(cursor.fetchone()[0])


    print(hr_name_list)
    return hr_name_list
    