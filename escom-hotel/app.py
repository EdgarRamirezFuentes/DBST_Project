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
from flask_cors import CORS



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

# Setup CORS
CORS(app, supports_credentials=True)

@app.route('/api/v1')
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

    try:
        conn = db.connect()

        if not conn:
            print("no conn")
            app.logger.critical( f'Database unavailable')
            return jsonify({'msg': 'Service unavailable.'}), 500

        with conn.cursor() as cursor:
            if not cursor:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            cursor.callproc('sp_login', (email, password))

            user_id, user_role = cursor.fetchone()

            if user_id == -1:
                app.logger.info(f'{email} failed to login')
                return jsonify({'msg': 'Invalid credentials.'}), 401

            access_token = create_access_token(
                identity={
                    'user_id' : user_id,
                    'user_role' : user_role
                })

            response = jsonify({
                'msg' : 'login successful.',
                'user_id' : user_id,
                'user_role' : user_role
            })
            set_access_cookies(response, access_token)
            app.logger.info(f'User ID({user_id}) logged in successfully')
        return response

    except (IntegrityError, DatabaseError, InternalError,
            ProgrammingError, NotSupportedError,
            OperationalError, ColumnsWithoutNamesError) as e:
        app.logger.error(str(e))
        return jsonify({'message' : 'Error' }), 500
    except Warning as w:
        app.logger.warning(str(w))
        return jsonify({'message' : 'Error' }), 500
    except DataError as e:
        return jsonify({'message' : f'Error: {e}' }), 500
    finally:
        app.logger.info( f'<{email}> tried to login.')
        # if cursor:
        #     cursor.close()
        # if db:
        #     conn.close()


@app.route('/api/v1/auth/logout', methods=['POST'])
@jwt_required()
def logout():
    user_id = get_jwt_identity()['user_id']
    response = jsonify({'msg': 'logout successful.'})
    unset_jwt_cookies(response)
    app.logger.info(f'User ID({user_id}) logged out successfully')
    return response


##################
# ADMIN SECTION #
################

####### Role
@app.route('/api/v1/admin/role/', methods=['GET', 'POST'])
@jwt_required()
def role():
    user = get_jwt_identity()

    user_id = user['user_id']

    if request .method == 'GET':
        try:
            conn = db.connect()

            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401


                cursor.callproc('sp_rol_crud', (None, None, 'FINDALL'))
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
            app.logger.info( f'User ID({user_id}) retrieved the Role table data')
            if cursor:
                cursor.close()
            if db:
                conn.close()


    elif request.method == 'POST':
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

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_rol_crud', (None, role_name.lower(), 'INSERT'))
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
            app.logger.info(f'User ID({user_id}) inserted the {role_name} role into the Rol table')
            if cursor:
                cursor.close()
            if db:
                db.close()


####### Role by id
@app.route('/api/v1/admin/role/<int:id>', methods=['GET', 'PUT', 'DELETE'])
@jwt_required()
def role_by_id(id : int):
    user = get_jwt_identity()
    user_id = user['user_id']

    if request.method == 'GET':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

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
            app.logger.info(f'User ID({user_id}) retrieved the role with id {id}')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'PUT':
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

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_rol_crud', (id, role_name.lower(), 'UPDATE'))
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
            app.logger.info(f'User ID({user_id}> inserted the {role_name} role into the Rol table')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'DELETE':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

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
            app.logger.info(f'User ID({user_id}) deleted the role with id {id}')
            if cursor:
                cursor.close()
            if db:
                db.close()

####### Employee
@app.route('/api/v1/admin/employee', methods=['GET', 'POST'])
@jwt_required()
def employee():
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        conn = db.connect()

        try:
            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical( f'Database unavailable')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_empleado_crud',
                (
                    None, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    None, None, ## Employee data
                    'FINDALL' ## Action
                ))
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
            app.logger.info(f'User ID({user_id}) retrieved all employees')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'POST':
        data = request.get_json()

        employee_name = data['nombre'].lower()
        employee_last_name = data['apPaterno'].lower()
        employee_second_last_name = data['apMaterno'].lower()
        employee_birth_date = data['fechaNacimiento']
        employee_gender = data['genero'].lower()
        employee_curp = data['curp'].upper()
        employee_rfc = data['rfc'] if data['rfc'].upper() else  None
        employee_phone = data['telefono']
        employee_email = data['correo']
        employee_password = data['contrasenia']
        employee_role = data['idRol']

        if (
            not employee_name
            or not employee_last_name
            or not employee_second_last_name
            or not employee_birth_date
            or not employee_gender
            or not employee_curp
            or not employee_phone
            or not employee_email
            or not employee_password
            or not employee_role
        ):
            return jsonify({'msg': 'Missing user data.'}), 400

        employee_street = data['calle'].lower()
        employee_ext_number = data['numeroExterior']
        employee_int_number = data['numeroInterior']
        employee_neighborhood = data['colonia'].lower()
        employee_state = data['estado'].lower()
        employee_district = data['alcaldia'].lower()
        employee_postal_code = data['codigoPostal']


        if (
            not employee_street
            or not employee_ext_number
            or not employee_neighborhood
            or not employee_state
            or not employee_district
            or not employee_postal_code
        ):
            return jsonify({'msg': 'Missing address data.'}), 400

        employee_emergency_contact_name = data['nombreContactoEmergencia'].lower()
        employee_emergency_contact_last_name = data['apPaternoContactoEmergencia'].lower()
        employee_emergency_contact_second_last_name = data['apMaternoContactoEmergencia'].lower()
        employee_emergency_contact_phone = data['telefonoContactoEmergencia']

        if (
            not employee_emergency_contact_name
            or not employee_emergency_contact_last_name
            or not employee_emergency_contact_second_last_name
            or not employee_emergency_contact_phone
        ):
            return jsonify({'msg': 'Missing emergency contact data.'}), 400

        employee_salary = data['salario']
        employee_area = data['idArea']

        if (
            not employee_salary
            or not employee_area
        ):
            return jsonify({'msg': 'Missing employee data.'}), 400

        try:
            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_empleado_crud',
                (
                    None, # idUsuario
                    employee_name, employee_last_name, employee_second_last_name, ## User data
                    employee_birth_date, employee_gender, employee_curp, employee_rfc,
                    employee_phone, employee_email, employee_password, employee_role,
                    employee_street, employee_ext_number, employee_int_number, employee_neighborhood, ## Address data
                    employee_state, employee_district, employee_postal_code,
                    employee_emergency_contact_name, employee_emergency_contact_last_name, ## Contact data
                    employee_emergency_contact_second_last_name, employee_emergency_contact_phone,
                    employee_salary, employee_area, ## Employee data
                    'INSERT' ## Action
                ))

                response = cursor.fetchone()

                conn.commit()

                return jsonify(response), 200

        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError, OperationalError,
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
            app.logger.info(f'User ID({user_id}> registered a new employee')
            if cursor:
                cursor.close()
            if db:
                db.close()


####### Employee by id
@app.route('/api/v1/admin/employee/<int:employee_id>', methods=['GET', 'PUT', 'DELETE'])
@jwt_required()
def employee_by_id(employee_id):
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        try:
            conn = db.connect()
            if not conn:
                app.logger.critical('Database unavailable.')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical('Database unavailable.')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401
                print(user_id)
                cursor.callproc('sp_empleado_crud',
                (
                    employee_id, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    None, None, ## Employee data
                    'FIND' ## Action
                ))
                response = cursor.fetchone()
                return jsonify(response), 200
        except OperationalError as e:
            print(e)
            return jsonify({'msg':f'There is no employee with id {employee_id}'}), 404
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
            app.logger.info(f'User ID({user_id}> accessed employee ID({employee_id})')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'PUT':
        data = request.get_json()

        employee_name = data['nombre'].lower()
        employee_last_name = data['apPaterno'].lower()
        employee_second_last_name = data['apMaterno'].lower()
        employee_birth_date = data['fechaNacimiento']
        employee_gender = data['genero'].lower()
        employee_curp = data['curp'].upper()
        employee_rfc = data['rfc'] if data['rfc'].upper() else  None
        employee_phone = data['telefono']
        employee_email = data['correo']
        employee_password = data['contrasenia']
        employee_role = data['idRol']

        if (
            not employee_name
            or not employee_last_name
            or not employee_second_last_name
            or not employee_birth_date
            or not employee_gender
            or not employee_curp
            or not employee_phone
            or not employee_email
            or not employee_password
            or not employee_role
        ):
            return jsonify({'msg': 'Missing user data.'}), 400

        employee_street = data['calle'].lower()
        employee_ext_number = data['numeroExterior']
        employee_int_number = data['numeroInterior']
        employee_neighborhood = data['colonia'].lower()
        employee_state = data['estado'].lower()
        employee_district = data['alcaldia'].lower()
        employee_postal_code = data['codigoPostal']


        if (
            not employee_street
            or not employee_ext_number
            or not employee_neighborhood
            or not employee_state
            or not employee_district
            or not employee_postal_code
        ):
            return jsonify({'msg': 'Missing address data.'}), 400

        employee_emergency_contact_name = data['nombreContactoEmergencia'].lower()
        employee_emergency_contact_last_name = data['apPaternoContactoEmergencia'].lower()
        employee_emergency_contact_second_last_name = data['apMaternoContactoEmergencia'].lower()
        employee_emergency_contact_phone = data['telefonoContactoEmergencia']

        if (
            not employee_emergency_contact_name
            or not employee_emergency_contact_last_name
            or not employee_emergency_contact_second_last_name
            or not employee_emergency_contact_phone
        ):
            return jsonify({'msg': 'Missing emergency contact data.'}), 400

        employee_salary = data['salario']
        employee_area = data['idArea']

        if (
            not employee_salary
            or not employee_area
        ):
            return jsonify({'msg': 'Missing employee data.'}), 400

        try:
            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_empleado_crud',
                (
                    employee_id, # idUsuario
                    employee_name, employee_last_name, employee_second_last_name, ## User data
                    employee_birth_date, employee_gender, employee_curp, employee_rfc,
                    employee_phone, employee_email, employee_password, employee_role,
                    employee_street, employee_ext_number, employee_int_number, employee_neighborhood, ## Address data
                    employee_state, employee_district, employee_postal_code,
                    employee_emergency_contact_name, employee_emergency_contact_last_name, ## Contact data
                    employee_emergency_contact_second_last_name, employee_emergency_contact_phone,
                    employee_salary, employee_area, ## Employee data
                    'UPDATE' ## Action
                ))

                response = cursor.fetchone()

                conn.commit()

                return jsonify(response), 200

        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError, OperationalError,
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
            app.logger.info(f'User ID({user_id}> registered a new employee')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'DELETE':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical( f'Database unavailable')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_empleado_crud',
                (
                    employee_id, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    None, None, ## Employee data
                    'DELETE' ## Action
                ))
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
            app.logger.info(f'User ID({user_id}) deleted the role with id {id}')
            if cursor:
                cursor.close()
            if db:
                db.close()

####### Customer
@app.route('/api/v1/admin/customer', methods=['GET', 'POST'])
@jwt_required()
def customer():
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        conn = db.connect()

        try:
            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical( f'Database unavailable')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_cliente_crud',
                (
                    None, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    'FINDALL' ## Action
                ))
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
            app.logger.info(f'User ID({user_id}) retrieved all customers')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'POST':
        data = request.get_json()

        customer_name = data['nombre'].lower()
        customer_last_name = data['apPaterno'].lower()
        customer_second_last_name = data['apMaterno'].lower()
        customer_birth_date = data['fechaNacimiento']
        customer_gender = data['genero'].lower()
        customer_curp = data['curp'].upper()
        customer_rfc = data['rfc'] if data['rfc'].upper() else  None
        customer_phone = data['telefono']
        customer_email = data['correo']
        customer_password = data['contrasenia']
        customer_role = data['idRol']

        if (
            not customer_name
            or not customer_last_name
            or not customer_second_last_name
            or not customer_birth_date
            or not customer_gender
            or not customer_curp
            or not customer_phone
            or not customer_email
            or not customer_password
            or not customer_role
        ):
            return jsonify({'msg': 'Missing user data.'}), 400

        customer_street = data['calle'].lower()
        customer_ext_number = data['numeroExterior']
        customer_int_number = data['numeroInterior']
        customer_neighborhood = data['colonia'].lower()
        customer_state = data['estado'].lower()
        customer_district = data['alcaldia'].lower()
        customer_postal_code = data['codigoPostal']


        if (
            not customer_street
            or not customer_ext_number
            or not customer_neighborhood
            or not customer_state
            or not customer_district
            or not customer_postal_code
        ):
            return jsonify({'msg': 'Missing address data.'}), 400

        customer_emergency_contact_name = data['nombreContactoEmergencia'].lower()
        customer_emergency_contact_last_name = data['apPaternoContactoEmergencia'].lower()
        customer_emergency_contact_second_last_name = data['apMaternoContactoEmergencia'].lower()
        customer_emergency_contact_phone = data['telefonoContactoEmergencia']

        if (
            not customer_emergency_contact_name
            or not customer_emergency_contact_last_name
            or not customer_emergency_contact_second_last_name
            or not customer_emergency_contact_phone
        ):
            return jsonify({'msg': 'Missing emergency contact data.'}), 400

        try:
            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_cliente_crud',
                (
                    None, # idUsuario
                    customer_name, customer_last_name, customer_second_last_name, ## User data
                    customer_birth_date, customer_gender, customer_curp, customer_rfc,
                    customer_phone, customer_email, customer_password, customer_role,
                    customer_street, customer_ext_number, customer_int_number, customer_neighborhood, ## Address data
                    customer_state, customer_district, customer_postal_code,
                    customer_emergency_contact_name, customer_emergency_contact_last_name, ## Contact data
                    customer_emergency_contact_second_last_name, customer_emergency_contact_phone,
                    'INSERT' ## Action
                ))

                response = cursor.fetchone()

                conn.commit()

                return jsonify(response), 200

        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError, OperationalError,
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
            app.logger.info(f'User ID({user_id}> registered a new customer')
            if cursor:
                cursor.close()
            if db:
                db.close()


### Customer by id
@app.route('/api/v1/admin/customer/<int:customer_id>', methods=['GET','PUT','DELETE'])
@jwt_required()
def customer_by_id(customer_id):
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        try:
            conn = db.connect()
            if not conn:
                app.logger.critical('Database unavailable.')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical('Database unavailable.')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401
                print(user_id)
                cursor.callproc('sp_cliente_crud',
                (
                    customer_id, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    'FIND' ## Action
                ))
                response = cursor.fetchone()
                return jsonify(response), 200
        except OperationalError as e:
            print(e)
            return jsonify({'msg':f'There is no customer with id {customer_id}'}), 404
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
            app.logger.info(f'User ID({user_id}> accessed customer ID({customer_id})')
            if cursor:
                cursor.close()
            if db:
                db.close()

    if request.method == 'PUT':
        data = request.get_json()

        customer_name = data['nombre'].lower()
        customer_last_name = data['apPaterno'].lower()
        customer_second_last_name = data['apMaterno'].lower()
        customer_birth_date = data['fechaNacimiento']
        customer_gender = data['genero'].lower()
        customer_curp = data['curp'].upper()
        customer_rfc = data['rfc'] if data['rfc'].upper() else  None
        customer_phone = data['telefono']
        customer_email = data['correo']
        customer_password = data['contrasenia']
        customer_role = data['idRol']

        if (
            not customer_name
            or not customer_last_name
            or not customer_second_last_name
            or not customer_birth_date
            or not customer_gender
            or not customer_curp
            or not customer_phone
            or not customer_email
            or not customer_password
            or not customer_role
        ):
            return jsonify({'msg': 'Missing user data.'}), 400

        customer_street = data['calle'].lower()
        customer_ext_number = data['numeroExterior']
        customer_int_number = data['numeroInterior']
        customer_neighborhood = data['colonia'].lower()
        customer_state = data['estado'].lower()
        customer_district = data['alcaldia'].lower()
        customer_postal_code = data['codigoPostal']


        if (
            not customer_street
            or not customer_ext_number
            or not customer_neighborhood
            or not customer_state
            or not customer_district
            or not customer_postal_code
        ):
            return jsonify({'msg': 'Missing address data.'}), 400

        customer_emergency_contact_name = data['nombreContactoEmergencia'].lower()
        customer_emergency_contact_last_name = data['apPaternoContactoEmergencia'].lower()
        customer_emergency_contact_second_last_name = data['apMaternoContactoEmergencia'].lower()
        customer_emergency_contact_phone = data['telefonoContactoEmergencia']

        if (
            not customer_emergency_contact_name
            or not customer_emergency_contact_last_name
            or not customer_emergency_contact_second_last_name
            or not customer_emergency_contact_phone
        ):
            return jsonify({'msg': 'Missing emergency contact data.'}), 400
        
        try:
            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_cliente_crud',
                (
                    customer_id, # idUsuario
                    customer_name, customer_last_name, customer_second_last_name, ## User data
                    customer_birth_date, customer_gender, customer_curp, customer_rfc,
                    customer_phone, customer_email, customer_password, customer_role,
                    customer_street, customer_ext_number, customer_int_number, customer_neighborhood, ## Address data
                    customer_state, customer_district, customer_postal_code,
                    customer_emergency_contact_name, customer_emergency_contact_last_name, ## Contact data
                    customer_emergency_contact_second_last_name, customer_emergency_contact_phone,
                    'UPDATE' ## Action
                ))

                response = cursor.fetchone()

                conn.commit()

                return jsonify(response), 200

        except (IntegrityError, DatabaseError, InternalError,
                ProgrammingError, NotSupportedError, OperationalError,
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
            app.logger.info(f'User ID({user_id}> registered a new customer')
            if cursor:
                cursor.close()
            if db:
                db.close()
    
    if request.method == 'DELETE':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical( f'Database unavailable')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_cliente_crud',
                (
                    customer_id, # idUsuario
                    None, None, None, None, ## User data
                    None, None, None,None,
                    None, None, None,
                    None, None, None, None, ## Address data
                    None, None, None,
                    None,None, None, None, ## Contact data
                    'DELETE' ## Action
                ))
                response = cursor.fetchone()
                conn.commit()


                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({'msg':f'There is no customer with id {id}'}), 404
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
            app.logger.info(f'User ID({user_id}) deleted the customer with id {id}')
            if cursor:
                cursor.close()
            if db:
                db.close()
        
###### Type Room
@app.route('/api/v1/admin/typeroom', methods=['GET','POST'])
@jwt_required()
def type_room():
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        try:
            conn = db.connect()

            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401


                cursor.callproc('sp_tipo_habitacion_crud', (None, None ,None ,None , None, 'FINDALL'))
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
            app.logger.info( f'User ID({user_id}) retrieved the type room table type')
            if cursor:
                cursor.close()
            if db:
                conn.close()
    
    elif request.method == 'POST':
        data = request.get_json()

        type_room_name = data['nombre'].lower()
        type_room_camas = data['numCamas']
        type_room_personas = data['numPersonas']
        type_room_precio = data['precio']

        if( not type_room_name
            or not type_room_camas
            or not type_room_personas
            or not type_room_precio
        ):
            return jsonify({'msg' : 'Missing data type room'}), 400

        try:
            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_tipo_habitacion_crud', (None, 
                type_room_name, type_room_camas, 
                type_room_personas, type_room_precio, 'INSERT'))

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
            app.logger.info(f'User ID({user_id}) inserted the {type_room_name} type room into the type room table')
            if cursor:
                cursor.close()
            if db:
                db.close()


@app.route('/api/v1/admin/typeroom/<int:typeroom_id>', methods=['GET','PUT','DELETE'])
@jwt_required()
def type_room_id(typeroom_id):
    user_id = get_jwt_identity()['user_id']

    if request.method == 'GET':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_tipo_habitacion_crud', (typeroom_id, None ,None ,None , None, 'FIND'))

                response = cursor.fetchone()
                return jsonify(response), 200
        except OperationalError as e:
                    return jsonify({'msg':f'There is no type room with id {typeroom_id}'}), 404
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
            app.logger.info(f'User ID({user_id}) retrieved the type room with id {id}')
            if cursor:
                cursor.close()
            if db:
                db.close()

    elif request.method == 'PUT':
        data = request.get_json()

        nombre_tipo = data['nombre'].lower()
        camas_tipo = data['numCamas']
        personas_tipo = data['numPersonas']
        precio_tipo = data['precio']

        if (
            not nombre_tipo or not camas_tipo or not personas_tipo or not precio_tipo
        ):
            return jsonify({'msg': 'Missing type room data.'}), 400

        try:
            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access role without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_tipo_habitacion_crud', 
                (typeroom_id, nombre_tipo.lower(), camas_tipo
                ,personas_tipo , precio_tipo,'UPDATE'))
                response = cursor.fetchone()
                conn.commit()
                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({'msg' : f'There is no type room with id {typeroom_id}'}), 404
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
            app.logger.info(f'User ID({user_id}> inserted the {nombre_tipo} type room into the type room table')
            if cursor:
                cursor.close()
            if db:
                db.close()
    
    elif request.method == 'DELETE':
        conn = db.connect()

        try:

            conn = db.connect()
            if not conn:
                app.logger.critical( f'Database unavailable')
                return jsonify({'msg': 'Service unavailable.'}), 500

            with conn.cursor(as_dict=True) as cursor:
                if not cursor:
                    app.logger.critical( f'Database unavailable')
                    return jsonify({'msg': 'Service unavailable.'}), 500

                cursor.callproc('sp_obtenerRolUsuario', (user_id,))

                user_role = cursor.fetchone()['rol'].lower()

                if not user_role or user_role != "administrador":
                    app.logger.warning(f'User ID({user_id}) tried to access employee without permission')
                    return jsonify({'msg': 'You have no permissions to execute this action.'}), 401

                cursor.callproc('sp_tipo_habitacion_crud',
                (
                    typeroom_id, # idUsuario
                    None, None, None, None, ## User data
                    'DELETE' ## Action
                ))
                response = cursor.fetchone()
                conn.commit()


                return jsonify(response), 200

        except OperationalError as e:
                    return jsonify({'msg':f'There is no type room with id {typeroom_id}'}), 404
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
            app.logger.info(f'User ID({user_id}) deleted the type room with id {typeroom_id}')
            if cursor:
                cursor.close()
            if db:
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
