from flask import Flask, request, jsonify
from flask_cors import CORS
from models import db, User
from config import Config

import re
import datetime

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

db.init_app(app)

with app.app_context():
    db.create_all()

def validate_phone(phone):
    pattern = r'^\+?[1-9]\d{1,14}$'
    return re.match(pattern, phone) is not None

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

@app.route('/api/check-user', methods=['POST'])
def check_user():
    data = request.get_json()
    phone = data.get('phone')
    
    if not phone or not validate_phone(phone):
        return jsonify({'error': 'Invalid phone number'}), 400
    
    user = User.query.filter_by(phone=phone).first()
    
    return jsonify({
        'exists': user is not None,
        'requires_password': user is not None
    })

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    phone = data.get('phone')
    password = data.get('password')
    
    if not phone or not password:
        return jsonify({'error': 'Phone and password are required'}), 400
    
    user = User.query.filter_by(phone=phone).first()
    
    if not user or not user.check_password(password):
        return jsonify({'error': 'Invalid phone or password'}), 401
    
    token = user.generate_token()
    
    return jsonify({
        'token': token,
        'user': {
            'id': user.id,
            'phone': user.phone,
            'full_name': user.full_name,
            'email': user.email
        }
    })

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    
    required_fields = ['phone', 'password', 'full_name', 'email', 'birth_date']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} is required'}), 400
    
    phone = data.get('phone')
    email = data.get('email')
    
    if not validate_phone(phone):
        return jsonify({'error': 'Invalid phone number'}), 400
    
    if not validate_email(email):
        return jsonify({'error': 'Invalid email address'}), 400
    
    if User.query.filter_by(phone=phone).first():
        return jsonify({'error': 'Phone number already registered'}), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already registered'}), 400
    
    user = User(
        phone=phone,
        full_name=data.get('full_name'),
        email=email,
        birth_date=datetime.datetime.strptime(data.get('birth_date'), '%Y-%m-%d').date()
    )
    user.set_password(data.get('password'))
    
    db.session.add(user)
    db.session.commit()
    
    token = user.generate_token()
    
    return jsonify({
        'token': token,
        'user': {
            'id': user.id,
            'phone': user.phone,
            'full_name': user.full_name,
            'email': user.email
        }
    }), 201

@app.route('/api/profile', methods=['GET'])
def get_profile():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({'error': 'Token is required'}), 401
    
    user = User.verify_token(token.replace('Bearer ', ''))
    if not user:
        return jsonify({'error': 'Invalid token'}), 401
    
    return jsonify({
        'user': {
            'id': user.id,
            'phone': user.phone,
            'full_name': user.full_name,
            'email': user.email,
            'birth_date': user.birth_date.isoformat() if user.birth_date else None
        }
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)