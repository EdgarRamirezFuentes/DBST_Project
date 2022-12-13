# ESCOM HOTEL ENDPOINTS

## **Auth endpoints**

|  Module |  Submodule  |    Endpoint    |     HTTP    |  CSRF TOKEN  | JSON body | Description |
|:-------:|:----------:|:--------------:|:-----------:|:------------:|:----------:|:------------:|
| **Auth** | Login | **/api/v1/auth/login** | POST | NO | ```{"email" : "email@example.com", "password" : "example_password"}``` | Sign in |
| **Auth** | Logout | **/api/v1/auth/login** | POST | YES | ```{}``` | Sign out |
| **Admin** | Role | **/api/v1/auth/role** | GET | YES | ```{}``` | Get  all the roles |
| **Admin** | Role | **/api/v1/auth/role** | POST | YES | ```{"role_name" : "example role"}``` | Register a new role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | GET | YES | ```{}``` | Get the role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | PUT | YES | ```{"role_name" : "update role"}``` | Update the role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | DELETE | YES | ```{}``` | Delete the role |
| **Admin** | Employee | **/api/v1/auth/employee** | GET | YES | ```{}``` | Get  all the employees |
| **Admin** | Employee | **/api/v1/auth/employee** | POST | YES | ```{"nombre" : "test name", "apPaterno" : "test last name", "apMaterno" : "test second last name", "fechaNacimiento" : "1990-09-15", "genero": "F", "curp": "EEEE000000EEEEEE00", "rfc": "EEEE000000EEE", "telefono": "5512084633", "correo" : "employee@employee.com", "contrasenia" : "employee password", "idRol" : 2, "calle" : "test street", "numeroExterior" : "12","numeroInterior" : "115", "colonia" : "test neighborhood", "estado" : "test state", "alcaldia" : "test district", "codigoPostal" : "00000", "nombreContactoEmergencia" : "test contact name", "apPaternoContactoEmergencia" : "test contact last name", "apMaternoContactoEmergencia" : "test contact second last name", "telefonoContactoEmergencia" : "5672064621", "salario" : 17000.50, "idArea" : 1}``` | Register an employee |




