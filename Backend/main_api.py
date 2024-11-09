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
        user_hr_id = data['hr_lead_id']
    else:
        user_hr_id = ''
        
    return jsonify(create_new_user(username=username, role=role, password=password, id=id, user_hr_id=user_hr_id))
    if request.method == 'OPTIONS':
        return jsonify({'message': 'Good'})

# Возможно придется добавить проверку столбца Active – ведь пользователь может быть удален
# Подумать об удалении пользователя
@app.route('/user/login', methods=['POST'])
def login():
    data = request.get_json()
    name = data['username']
    password = data['password']
    result = entry.login(name, password)
    # {'result': True, 'id': 1234}
    return jsonify(result)
    if request.method == 'OPTIONS':
        return jsonify({'message': 'Good'})
    
 
 
@app.route('/resume/create', methods=['POST'])
def create_resume():
    data = request.get_json()
    vacancy = data['vacancy']
    age = data['age']
    source = data['source']
    user_id = data['id']
    name = data['name']
    # try:
    

    resume.create(name=name, vacancy=vacancy, age=age, source=source, hr_user_id=user_id)  
    return jsonify({'response' :'created'})
    # except:
    #     return jsonify({'response' :'not created'})
    

# Возможен отвал базы
# @app.route('/connect')
# def serverConnect():
#     if(createBase.createBase()):
#     return "Good"
#     return "Database error"


@app.route('/user/getRole')
def get_role():
    return get_role




if __name__ == '__main__':
    # app.run(host='0.0.0.0')
    app.run()
