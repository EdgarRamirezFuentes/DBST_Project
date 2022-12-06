from pymssql import (
    IntegrityError,
    ProgrammingError,
    DataError,
    OperationalError,
    NotSupportedError,
    ColumnsWithoutNamesError, 
    DataError,
    DatabaseError,
    Warning,
    InternalError
)

from flask import (
    Flask, 
    jsonify, 
    request,
)

from datetime import ( 
    timedelta,
    datetime, 
    timezone
)

# jwt
from flask_jwt_extended import (
    create_access_token,
    get_jwt,
    get_jwt_identity,
    jwt_required,
    JWTManager,
    set_access_cookies,
    unset_jwt_cookies,
)



import os
from logging.config import dictConfig
from util import DatabaseConnector


# DB Setup
db = DatabaseConnector(
        os.environ.get('USERNAME'), 
        os.environ.get('PASSWORD'),
        os.environ.get('SERVER'),
        os.environ.get('DATABASE'))

# Logger Setup
dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {
        'wsgi': {
            'class': 'logging.StreamHandler',
            'stream': 'ext://flask.logging.wsgi_errors_stream',
            'formatter': 'default'
        },
        'file' : {
            'class' : 'logging.handlers.RotatingFileHandler',
            'formatter': 'default',
            'filename': 'logconfig.log',
        }
    },
    'root': {
        'level': 'INFO',
        'handlers': ['wsgi', 'file']
    },
})


app = Flask(__name__)

# Setup JWT
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY')


# If true this will only allow the cookies that contain your JWTs to be sent
# over https. In production, this should always be set to True
#https://flask-jwt-extended.readthedocs.io/en/stable/refreshing_tokens/
app.config['JWT_COOKIE_SECURE'] = False
app.config['JWT_TOKEN_LOCATION'] = ['cookies']
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)


jwt  = JWTManager(app)

@app.route('/')
def main():
    return jsonify('Hello.')


#################
# AUTH SECTION #
###############

# Using an `after_request` callback, we refresh any token that is within 30
# minutes of expiring. Change the timedeltas to match the needs of your application.
@app.after_request
def refresh_expiring_jwts(response):
    try:
        exp_timestamp = get_jwt()['exp']
        now = datetime.now(timezone.utc)
        target_timestamp = datetime.timestamp(now + timedelta(minutes=30))
        if target_timestamp > exp_timestamp:
            access_token = create_access_token(identity=get_jwt_identity())
            set_access_cookies(response, access_token)
        return response
    except (RuntimeError, KeyError):
        # Case where there is not a valid JWT. Just return the original response
        return response


@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    email = request.json.get('email', None)
    password = request.json.get('password', None)

    if not email or not password:
        return jsonify({'msg':'email and password are required'}), 400

    access_token = create_access_token(identity={'email' : email, 'role': 'admin'})
    response = jsonify({'msg' : 'login successful.'})
    set_access_cookies(response, access_token)
    app.logger.info(f'{email} logged in successfully')
    return response


@app.route('/api/v1/auth/logout', methods=['POST'])
@jwt_required()
def logout():
    email = get_jwt_identity()['email']
    response = jsonify({'msg': 'logout successful.'})
    unset_jwt_cookies(response)
    app.logger.info(f'{email} logged out successfully')
    return response


##################
# ADMIN SECTION #
################

####### Role
@app.route('/api/v1/admin/role/', methods=['GET', 'POST'])
@jwt_required()
def role():
    user = get_jwt_identity()

    user_role = user['role']
    user_email = user['email']

    if not user_role == 'admin':
        app.logger.warning( f'<{user_email}> tried to access to an unauthorized endpoint')
        return jsonify({'msg':'unauthorized access.'}), 401

    if request .method == 'GET':
        try: 

            conn = db.connect()

            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_rol_crud', (None, None, 'SELECT'))
                response = cursor.fetchall() 
                
                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({}), 200
        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError,
                ColumnsWithoutNamesError) as e:
            app.logger.error(str(e))
            return jsonify({'message' : 'Error' }), 500
        except Warning as w:
            app.logger.warning(str(w))
            return jsonify({'message' : 'Error' }), 500
        except DataError as e:
            return jsonify({'message' : f'Error: {e}' }), 500
        finally:
            app.logger.info( f'<{user_email}> retrieved the Role table data')
            cursor.close()
            conn.close()
            

    if request.method == 'POST':
        role_name = request.json.get('role_name', '')

        if not role_name:
            return jsonify({'msg' : 'Role name required.'}), 400
        
        try:

            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_rol_crud', (None, role_name, 'INSERT'))
                response = cursor.fetchone()
                conn.commit()

                return jsonify(response), 201   

        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError,
                ColumnsWithoutNamesError) as e:
            app.logger.error(str(e))
            conn.rollback()
            return jsonify({'message' : 'Error' }), 500
        except Warning as w:
            app.logger.warning(str(w))
            conn.rollback()
            return jsonify({'message' : 'Error' }), 500
        except DataError as e:
            conn.rollback()
            return jsonify({'message' : f'Error: {e}' }), 500  
        finally:
            app.logger.info(f'<{user_email}> inserted the {role_name} role into the Rol table')
            cursor.close()
            db.close()


####### Role by id
@app.route('/api/v1/admin/role/<int:id>', methods=['GET', 'PUT', 'DELETE'])
@jwt_required()
def role_by_id(id : int):
    user = get_jwt_identity()
    user_email = user['email']
    user_role = user['role']

    if user_role != 'admin':
        app.logger.warning( f'<{user_email}> tried to access to an unauthorized endpoint')
        return jsonify({'msg':'unauthorized access.'}), 401

    if request.method == 'GET':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_rol_crud', (id, None, 'FIND'))

                response = cursor.fetchone()
                return jsonify(response), 200  
        except OperationalError as e:
                    return jsonify({'msg':f'There is no role with id {id}'}), 404
        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError,
                ColumnsWithoutNamesError) as e:
            app.logger.error(str(e))
            return jsonify({'message' : 'Error' }), 500
        except Warning as w:
            app.logger.warning(str(w))
            return jsonify({'message' : 'Error' }), 500
        except DataError as e:
            return jsonify({'message' : f'Error: {e}' }), 500  
        finally:
            app.logger.info(f'<{user_email}> retrieved the role with id {id}')
            cursor.close()
            db.close()

    if request.method == 'PUT':
        role_name = request.json.get('role_name', '')

        if not role_name:
            return jsonify({'msg' : 'Role name required.'}), 400
        
        try:

            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_rol_crud', (id, role_name, 'UPDATE'))
                response = cursor.fetchone()
                conn.commit()
                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({'msg' : f'There is no role with id {id}'}), 404
        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError,
                ColumnsWithoutNamesError) as e:
            app.logger.error(str(e))
            conn.rollback()
            return jsonify({'message' : 'Error' }), 500
        except Warning as w:
            app.logger.warning(str(w))
            conn.rollback()
            return jsonify({'message' : 'Error' }), 500
        except DataError as e:
            conn.rollback()
            return jsonify({'message' : f'Error: {e}' }), 500  
        finally:
            app.logger.info(f'<{user_email}> inserted the {role_name} role into the Rol table')
            cursor.close()
            db.close()

    if request.method == 'DELETE':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_rol_crud', (id, None, 'DELETE'))
                response = cursor.fetchone()
                conn.commit()

                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({'msg':f'There is no role with id {id}'}), 404
        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError,
                ColumnsWithoutNamesError) as e:
            conn.rollback()
            app.logger.error(str(e))
            return jsonify({'message' : 'Error' }), 500
        except Warning as w:
            app.logger.warning(str(w))
            conn.rollback()
            return jsonify({'message' : 'Error' }), 500
        except DataError as e:
            conn.rollback()
            return jsonify({'message' : f'Error: {e}' }), 500  
        finally:
            app.logger.info(f'<{user_email}> deleted the role with id {id}')
            cursor.close()
            db.close()


#########################
# RECEPCIONIST SECTION #
#######################


#########################
# ROOM SERVICE SECTION #
#######################


#####################
# CUSTOMER SECTION #
###################


#################
# USER SECTION #
###############


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='5000')
