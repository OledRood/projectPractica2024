

import os
from dotenv import load_dotenv
import mysql.connector

from models.admin.create_user import isAdmin
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





def deleteUser(user_id, admin_token, replace_hr, replace_hr_lead):
    admin_id = get_id_by_token(token=admin_token)
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    if(admin_id == False or (not isAdmin(id=admin_id, cursor=cursor))):
        close_base(cursor=cursor, connection=connection)
        return 'token error'
    
    cursor.execute('SELECT role FROM User where user_id = %s', (user_id, ))
    user_role = cursor.fetchone()[0]

    
    
    if(user_role == 'Hr' or replace_hr != -1):

        query = 'UPDATE resume SET hr_id = %s where hr_id=%s' 
        cursor.execute(query, (replace_hr, user_id))
        connection.commit()

        query = 'DELETE FROM hr WHERE hr_id = %s'
        cursor.execute(query, (user_id,))
        connection.commit()
        
        
        query = "DELETE FROM User WHERE user_id=%s"
        cursor.execute(query, (user_id,))
        connection.commit()
        
        close_base(connection=connection, cursor=cursor)
        return 'Hr deleted'

    if(user_role == 'Hr_lead'  or replace_hr_lead != -1):
        
        
        query = 'UPDATE hr SET hr_lead_id = %s WHERE hr_lead_id = %s'
        cursor.execute(query, (replace_hr_lead, user_id))
        connection.commit()
        
        
        query = 'DELETE FROM hr_lead WHERE hr_lead_id = %s'
        cursor.execute(query, (user_id,))
        connection.commit()
        
        query = "DELETE FROM User WHERE user_id = %s"
        cursor.execute(query, (user_id,))
        connection.commit()
        
        close_base(connection=connection, cursor=cursor)
        return "Hr_lead deleted"
    
    return 'user not delete'

