import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS

from models import entry
from routes.resume_api import resume_api
from routes.admin_api import admin_api



app = Flask(__name__)
CORS(app)

SECRET_KEY = 'secret_key'

app.register_blueprint(resume_api, url_prefix='/resume')
app.register_blueprint(admin_api, url_prefix='/admin')


# # Подумать об удалении пользователя
@app.route('/user/login', methods=['POST'])
def login():
    if request.method == 'OPTIONS':
        return jsonify({'message': 'Good'})
    
    data = request.get_json()
    name = data['username']
    password = data['password']

    result = entry.login(name, password)
    # {'result': True, 'id': 1234
    return jsonify(result)


