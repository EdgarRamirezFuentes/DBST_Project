import os
from pymssql import (
    Error
)
from flask import Flask, jsonify, request
from util import DatabaseConnector
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

db = DatabaseConnector(
        os.environ.get('USERNAME'), 
        os.environ.get('PASSWORD'),
        os.environ.get('SERVER'),
        os.environ.get('DATABASE'))

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

    response = jsonify({'msg' : 'login successful.'})
    access_token = create_access_token(identity={'email' : email, 'role': 'admin'})
    set_access_cookies(response, access_token)
    return response


@app.route('/api/v1/auth/logout', methods=['POST'])
def logout():
    response = jsonify({'msg': 'logout successful.'})
    unset_jwt_cookies(response)
    return response


##################
# ADMIN SECTION #
################
@app.route('/api/v1/admin/role/register', methods=['POST'])
@jwt_required()
def register_role():
    user = get_jwt_identity()

    if not user['role'] == 'admin':
        return jsonify({'msg':'unauthorized access.'}), 401

    name = request.json.get('role_name', '')

    if not name:
        return jsonify({'msg' : 'Role name required.'}), 400
    
    try:
        conn = db.connect()
        if not conn:
            return jsonify({'msg': 'Service unavailable.'}), 500

        with conn.cursor(as_dict=True) as cursor:
            if not cursor:
                return jsonify({'msg': 'Service unavailable.'}), 500

            cursor.callproc('sp_rol_crud', (None, name, 'INSERT'))

            inserted = cursor.fetchone()

            conn.commit()

            return jsonify(inserted), 201
    except Error  as e:
        return jsonify({'msg': str(e)}), 500
    finally:
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

@app.route('/api/v1/customer/signup', methods=['POST'])
def signin():
    """
        Usuario info = {
            nombre, * 
            apPaterno, *  
            apMaterno, *
            fechaNacimiento, *  
            curp, *
            rfc, 
            telefono, * 
            correo, *
            contrasenia, * 
            idRol, * 
            isActive *
        }

        Contacto emergencia info = {
            nombre, *
            apPaterno, *
            apMaterno, *
            telefono, *
            idUsuario *
        }

        Direccion Info = {
            calle, *
            numExterior, *
            numInterior, *
            colonia, *
            estado, *
            alcaldia, *
            codigoPostal, *
            idUsuario *
        }

        Cliento Info= {
            idUsuario *
        }
        Metodo de pago Info = {
            nombreEnTarjeta, * 
            numeroTarjeta, *
            cvv, *
            fechaVencimiento, * 
            idCliente *
        }

    """


#################
# USER SECTION #
###############
@app.route('/api/v1/user/info', methods=['GET'])
@jwt_required()
def get_user_data():
    try:
        jwt = get_jwt_identity()
        email = jwt['email']
        print(email)


        cursor = db.connect()

        if not cursor:
            return jsonify({'msg': 'Service unavailable.'}), 500

        cursor.execute(
            """
            SELECT idUsuario, correo, contrasenia 
            FROM Usuario
            WHERE correo = %s
            """, 
            (email, ))

        response = cursor.fetchone()

        if not response:
            return jsonify({'msg':'User does not exists'}), 400
            
        return jsonify(response), 200
    except:
        pass
    finally:
        db.close()



if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='5000')
