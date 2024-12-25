
from flask import Blueprint, jsonify, request
from models import resume, statistics
from models.hr_list import get_lists


resume_api = Blueprint('resume_api', __name__)



@resume_api.route('/create', methods=['POST'])
def create_resume():
    data = request.get_json()
    vacancy = data['vacancy']
    age = data['age']
    source = data['source']
    token = data['token']
    name = data['name']
    comments = data['comments']
    hr_name = data['hr_name']
    try:
        result = resume.create(name=name, vacancy=vacancy, age=age, source=source, token=token, comments=comments, hr_name=hr_name)  
        if(result == 'token error'):
            return jsonify({'response': "token error"})
        return jsonify({'response' : 'good'})
    except:
        
        return jsonify({'response' : 'bad'})
    
    
    
    
@resume_api.route('/search', methods=['POST'])
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
    status = data['status']
    token = data['token']
    hr_name = data['hr_name']
    from_date = data['from_date']
    to_date = data['to_date']
    result_search = resume.get_resume_with_filtres(search_text=search_text, vacancy=vacancy, age=age, name=name, source=source, archiv=archiv, status=status, token= token, hr_name_string=hr_name, to_date=to_date, from_date=from_date)
    if(result_search == 'token error'):
        print('result_search = ', result_search)
        return [{'resume_id': 'token error'}]
    return jsonify(resume.get_resume_with_filtres(search_text=search_text, vacancy=vacancy, age=age, name=name, source=source, archiv=archiv, status=status, token= token, hr_name_string=hr_name, to_date=to_date, from_date=from_date))
    
@resume_api.route('/update', methods=['POST'])
def update_resume():

    data = request.get_json()
    vacancy = data['vacancy']
    age = int(data['age'])
    source = data['source']
    comments = data['comments']
    archiv = int(data['archiv'])
    status = data['status']
    resume_id = data["resume_id"]
    hr_name = data['hr_name']
    token = data['token']
    name = data['name']
    try:
        status = resume.update(name=name, vacancy=vacancy, age=age, source=source, comments=comments, archiv=archiv, status=status, resume_id=resume_id, hr_name=hr_name, token=token )  
        if(status == 'created'):
            return jsonify({'response' : 'good'})
        elif(status == "token error"):
            return jsonify({'response': "token error"})
        else:
            return jsonify({'response': 'bad'})  
    except Exception as e:
        print("Ошибка: ", e)
        return jsonify({'response': 'bad'})     

@resume_api.route('/getResume', methods=['POST'])
def get_hr_resume():
    data = request.get_json()
    token = data['token']
    return jsonify(resume.get_resume(token=token))


# @app.route('/hr_lead/getHrList', methods=['POST'])
# def get_hr_list():
#     data = request.get_json();
#     user_id = int(data['user_id'])
    
#     return jsonify({'hr_list': get_hr_list(user_id=user_id)})


@resume_api.route('/getListsVacancyHrSource', methods=['POST'])
def getLists():
    data = request.get_json();
    token  = data['token'];
    return jsonify(get_lists(token))



@resume_api.route('/getStatistic', methods=['POST'])
def get_statistic():
    data = request.get_json()
    token = data["token"]

    return jsonify(statistics.get_resume_statistic(token))

