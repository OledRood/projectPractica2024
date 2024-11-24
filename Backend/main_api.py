# заменить строки
# create_base -> 
            # host='host.docker.internal',          # Замените на адрес MySQL сервера
# main ->
            # app.run(host='0.0.0.0')
 


from flask import Flask, jsonify, request

from database import entry, resume

from flask_cors import CORS

from database.create_user import create_new_user

app = Flask(__name__)
CORS(app)




# Добавить проверку, что должен делать админ
# Добавить не по id hr_lead'а, а по его имени(но тогда нужна функция, которая возвращает все имена)
@app.route('/user/registration', methods=['POST'])
def registration():
    data = request.get_json()
    username = data['username']
    role = data['role']
    password = data['password']
    # Подумать, возможно поменять на AdminID
    id = data['id']
    if(role == 'Hr'):
        hr_lead_id = data['hr_lead_id']
    else:
        hr_lead_id = ''
        
    return jsonify(create_new_user(username=username, role=role, password=password, id=id, hr_lead_id=hr_lead_id))
    if request.method == 'OPTIONS':
        return jsonify({'message': 'Good'})

# # Возможно придется добавить проверку столбца Active – ведь пользователь может быть удален
# # Подумать об удалении пользователя
@app.route('/user/login', methods=['POST'])
def login():
    if request.method == 'OPTIONS':
        return jsonify({'message': 'Good'})
    
    data = request.get_json()
    name = data['username']
    password = data['password']
    result = entry.login(name, password)
    # {'result': True, 'id': 1234}
    return jsonify(result)

 
 
@app.route('/resume/create', methods=['POST'])
def create_resume():
    data = request.get_json()
    vacancy = data['vacancy']
    age = data['age']
    source = data['source']
    user_id = data['id']
    name = data['name']
    comments = data['comments']
    try:
        resume.create(name=name, vacancy=vacancy, age=age, source=source, hr_user_id=user_id, comments=comments)  
        return jsonify({'response' : 'good'})
    except:
        return jsonify({'response' : 'bad'})
    
    
    
    
@app.route('/resume/search', methods=['POST'])
def search_resume():
    data = request.get_json()
    search_text = data['search_text']
    if search_text and search_text[-1] == " ":
        search_text = search_text[:-1]
    vacancy = data['vacancy']
    age = data['age']
    name = data['name']
    if name and name[-1] == " ":
        name = name[:-1]
    source = data['source']
    archiv = -1 if(data["archiv"] == "") else int(data['archiv'])
    print('Archiv: ', archiv)
    status = data['status']
    user_id = data['user_id']
    return resume.get_resume_with_filtres(search_text=search_text, vacancy=vacancy, age=age, name=name, source=source, archiv=archiv, status=status, user_id= user_id)
    
@app.route('/resume/update', methods=['POST'])
def update_resume():

    data = request.get_json()
    vacancy = data['vacancy']
    age = int(data['age'])
    source = data['source']
    comments = data['comments']
    archiv = int(data['archiv'])
    status = data['status']
    resume_id = data["resume_id"]
    
    name = data['name']
    try:
        status = resume.update(name=name, vacancy=vacancy, age=age, source=source, comments=comments, archiv=archiv, status=status, resume_id=resume_id)  
        if(status == 'created'):
            return jsonify({'response' : 'good'})
        else:
            print("не удалось сохранить")
            return jsonify({'response': 'bad'})  
    except Exception as e:
        print("Ошибка: ", e)
        return jsonify({'response': 'bad'})     

@app.route('/resume/getResume', methods=['POST'])
def get_hr_resume():
    data = request.get_json();
    user_id = int(data['user_id'])
    
    return jsonify(resume.get_resume(user_id=user_id));







if __name__ == '__main__':
    # app.run(host='0.0.0.0')
    app.run()













# Возможен отвал базы
# @app.route('/connect')
# def serverConnect():
#     if(createBase.createBase()):
#     return "Good"
#     return "Database error"


# @app.route('/user/getRole')
# def get_role():
#     return get_role
