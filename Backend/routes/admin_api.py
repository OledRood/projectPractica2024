
from flask import Blueprint, jsonify, request


from models.admin.delete_user import deleteUser
from models.admin.get_users_tables import get_users_tables
from models.admin.get_users_list import get_users_list
from models.admin.hr_lead_list import get_hr_lead_list  # Указываем файл, где определена функция
from models.admin.create_user import create_new_user


admin_api = Blueprint('admin_api', __name__)






# Добавить не по id hr_lead'а, а по его имени(но тогда нужна функция, которая возвращает все имена)
@admin_api.route('/registration', methods=['POST'])
def registration():
    data = request.get_json()
    username = data['username']
    user_role = data['role']
    user_password = data['password']
    token = data['token']
    
    if(user_role == 'Hr'):
        hr_lead_name = data['hr_lead_name']
    else:
        hr_lead_name = ''
    

    answer = create_new_user(username=username, user_role=user_role, password= user_password, token=token, hr_lead_name=hr_lead_name)


    if(isinstance (answer, str) and answer == 'token error'):
        return ({'response' : answer}, 401)
                     
    return jsonify(answer)


@admin_api.route('/delete', methods=['POST'])
def delete():
    data = request.get_json()
    token = data['token']
    user_id = data['user_id']
    replace_hr = data.get('replace_hr') or -1
    replace_hr_lead = data.get('replace_hr_lead') or -1
    
    return deleteUser(user_id=user_id, admin_token=token, replace_hr= replace_hr, replace_hr_lead=replace_hr_lead)






@admin_api.route('/getAllTables', methods=['POST'])
def get_all_tables():
    data = request.get_json()
    token  = data['token']
    return jsonify(get_users_tables(token=token))

@admin_api.route('/getUsersList', methods=["POST"])
def get_list_of_users(): 
    data = request.get_json()
    token = ['token']
    
    # print({'response': 'good', 'data' : get_users_list()})
    return {'response': 'good', 'data' : get_users_list()}
           


@admin_api.route('/getHrLeadList', methods=['POST'])
def get_hr_leads():
    data = request.get_json()
    token = data['token']
    

    return jsonify(get_hr_lead_list(token))