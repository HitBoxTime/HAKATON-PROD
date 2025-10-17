from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import jwt
import datetime

db = SQLAlchemy()
bcrypt = Bcrypt()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    full_name = db.Column(db.String(100), nullable=True)
    email = db.Column(db.String(100), nullable=True)
    birth_date = db.Column(db.Date, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def set_password(self, password):
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def generate_token(self):
        token = jwt.encode({
            'user_id': self.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, 'your-secret-key', algorithm='HS256')
        return token

    @staticmethod
    def verify_token(token):
        try:
            data = jwt.decode(token, 'your-secret-key', algorithms=['HS256'])
            return User.query.get(data['user_id'])
        except:
            return None