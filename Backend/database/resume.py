from datetime import datetime 
import mysql.connector
import os
from dotenv import load_dotenv

from database import logs





#  конвертировать строку обратоно в дату
# dt_object = datetime.strptime(dt_string, "%d/%m/%Y %H:%M:%S")

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



status_of_resume = {0: "Открыто", 1: "Изучена", 2: "Интервью", 3: "Прошли интервью", 4: "Техническое собеседование", 5: "Пройдено техническое собеседование", 6: "Оффер"}


def create(vacancy, age, source, hr_user_id, name, comments):
    archiv = 0;
    status = status_of_resume[0]
    date_last_changes = datetime.now()
    age = int(age)
    hr_user_id = int(hr_user_id)
    
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    
    
    insert_query = "INSERT INTO resume (name, vacancy, age, status, date_last_changes, source, hr_id, archiv, comments)  VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
    cursor.execute(insert_query, (name, vacancy, age, status, date_last_changes, source, hr_user_id, archiv, comments))
    connection.commit()
    
    query = "SELECT resume_id FROM resume WHERE date_last_changes = %s"
    cursor.execute(query, (date_last_changes,))
    resume_id = cursor.fetchone()[0] 
    close_base(connection=connection, cursor=cursor)

    logs.add_logs(resume_id=resume_id, new_status=status)
    
    
    
    
def update(vacancy, age, source, name, archiv, comments, status, resume_id):
    date_last_changes = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    age = int(age)
    
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    
    
    try:
        logs.add_logs(resume_id=resume_id, new_status=status)
        
        update_query = """
        UPDATE resume
        SET 
            vacancy = %s,
            age = %s,
            source = %s,
            name = %s,
            archiv = %s,
            comments = %s,
            status = %s,
            date_last_changes = %s
        WHERE resume_id = %s
        """

        cursor.execute(update_query, (vacancy, age, source, name, archiv, comments, status, date_last_changes, resume_id))
        connection.commit()   
    except Exception as e:
        print(e)
        close_base(connection=connection, cursor=cursor)
        return 'not created'
    close_base(connection=connection, cursor=cursor)
    return 'created'


def get_hr_list(user_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    cursor.execute("SELECT role FROM user WHERE user_id = %s", (user_id,))
    role_data = cursor.fetchone()[0]
    hr_list = []
    if(role_data == 'Hr_lead'):
        cursor.execute("SELECT hr_id FROM hr WHERE hr_lead_id = %s", (user_id,))
        hr_list = [hr_id[0] for hr_id in cursor.fetchall()]  # Извлекаем только hr_id из кортежей
    else: 
        hr_list.append(user_id)
    close_base(connection=connection, cursor=cursor)

    return hr_list



def get_resume(user_id):
    hr_list = get_hr_list(user_id=user_id)
    resumes = []

    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()

    for index in range(len(hr_list)):
        cursor.execute("SELECT * FROM resume WHERE hr_id = %s", (hr_list[index], ))
        resumes_data = cursor.fetchall()
        for row in resumes_data:
            cursor.execute("SELECT username FROM user WHERE user_id = %s", (row[8],))
            hr_name = cursor.fetchone()[0]
            resume = {
                "resume_id": row[0],
                "vacancy": row[1],
                "age": row[2],
                "status": row[3],
                "date_last_changes": row[4].strftime('%Y-%m-%d %H:%M:%S') if isinstance(row[4], datetime) else row[4],
                "source": row[5],
                "archiv": row[6],
                "name": row[7],
                "hr_name": hr_name,
                "comments": row[9] if row[9] is not None else "" 
            }
            resumes.append(resume)
            
    close_base(connection=connection, cursor=cursor)
    return resumes






def get_resume_with_filtres(search_text, vacancy, age, name, source, archiv, status, user_id):
    
    hr_list = get_hr_list(user_id=user_id)
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    # Для того, чтобы возвращались данные в виде словаря
    cursor = connection.cursor(dictionary=True)
    if(search_text != ""):



        query = """
            SELECT * 
            FROM resume
            WHERE 
                LOWER(vacancy) LIKE LOWER(%s) OR
                CAST(age AS CHAR) = %s OR
                LOWER(status) LIKE LOWER(%s) OR
                LOWER(source) LIKE LOWER(%s) OR
                LOWER(name) LIKE LOWER(%s) OR
                LOWER(comments) LIKE LOWER(%s)
        """
        
        search_pattern = f"%{search_text}%"
        params = (search_pattern, search_pattern, search_pattern, search_pattern, search_pattern, search_pattern)

        # Выполняем запрос
        cursor.execute(query, params)
    else: 
        query = """SELECT * FROM resume"""
        cursor.execute(query)
    
    listOfResumes = cursor.fetchall()
    result = []
    # print(listOfResumes)
    for resume in listOfResumes:

        flag = False
        if(not (resume["hr_id"] in hr_list)):
            flag = True
        if (vacancy != '') and (not (vacancy.lower() in resume["vacancy"].lower())):
            flag = True
        if (name != '') and (not (name.lower() in resume["name"].lower())):
            flag = True
        if (source != '') and (not (source.lower() in resume["source"].lower())):
            flag = True
        if (archiv != -1) and (archiv != resume["archiv"]):
            flag = True
        if (status != '') and (not (status.lower() in resume["status"].lower())):
            flag = True
        if (age != "") and (int(age) != resume["age"]):
            flag = True


            
        if not flag:
            cursor.execute("SELECT username FROM user WHERE user_id = %s", (resume['hr_id'],))
            hr_name = cursor.fetchone()

            resume['hr_name'] = hr_name['username']
            result.append(resume)
        
    close_base(connection=connection, cursor=cursor)

    # print('result: ', len(result))
    return result

    
    
    




    

