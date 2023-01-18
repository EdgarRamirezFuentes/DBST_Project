# ESCOM HOTEL ENDPOINTS

## **Auth endpoints**

|  Module |  Submodule  |    Endpoint    |     HTTP    |  CSRF TOKEN  | JSON body | Description |
|:-------:|:----------:|:--------------:|:-----------:|:------------:|:----------:|:------------:|
| **Auth** | Login | **/api/v1/auth/login** | POST | NO | ```{"email" : "email@example.com", "password" : "example_password"}``` | Sign in |
| **Auth** | Logout | **/api/v1/auth/logout** | POST | YES | ```{}``` | Sign out |
| **Admin** | Role | **/api/v1/admin/role** | GET | YES | ```{}``` | Get  all the roles |
| **Admin** | Role | **/api/v1/admin/role** | POST | YES | ```{"role_name" : "example role"}``` | Register a new role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | GET | YES | ```{}``` | Get the role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | PUT | YES | ```{"role_name" : "update role"}``` | Update the role |
| **Admin** | Role | **/api/v1/admin/role/\<int:id>** | DELETE | YES | ```{}``` | Delete the role |
| **Admin** | Employee | **/api/v1/admin/employee** | GET | YES | ```{}``` | Get all the employees |
| **Admin** | Employee | **/api/v1/admin/employee** | POST | YES | ```{"nombre" : "test name", "apPaterno" : "test last name", "apMaterno" : "test second last name", "fechaNacimiento" : "1990-09-15", "genero": "F", "curp": "EEEE000000EEEEEE00", "rfc": "EEEE000000EEE", "telefono": "5512084633", "correo" : "employee@employee.com", "contrasenia" : "employee password", "idRol" : 2, "calle" : "test street", "numeroExterior" : "12","numeroInterior" : "115", "colonia" : "test neighborhood", "estado" : "test state", "alcaldia" : "test district", "codigoPostal" : "00000", "nombreContactoEmergencia" : "test contact name", "apPaternoContactoEmergencia" : "test contact last name", "apMaternoContactoEmergencia" : "test contact second last name", "telefonoContactoEmergencia" : "5672064621", "salario" : 17000.50, "idArea" : 1}``` | Register a new employee |
| **Admin** | Employee | **/api/v1/admin/employee/\<int:employee_id>** | GET | YES | ```{}``` | Get the employee |
| **Admin** | Employee | **/api/v1/admin/employee** | PUT | YES | ```{"nombre" : "test name", "apPaterno" : "test last name", "apMaterno" : "test second last name", "fechaNacimiento" : "1990-09-15", "genero": "F", "curp": "EEEE000000EEEEEE00", "rfc": "EEEE000000EEE", "telefono": "5512084633", "correo" : "employee@employee.com", "contrasenia" : "employee password", "idRol" : 2, "calle" : "test street", "numeroExterior" : "12","numeroInterior" : "115", "colonia" : "test neighborhood", "estado" : "test state", "alcaldia" : "test district", "codigoPostal" : "00000", "nombreContactoEmergencia" : "test contact name", "apPaternoContactoEmergencia" : "test contact last name", "apMaternoContactoEmergencia" : "test contact second last name", "telefonoContactoEmergencia" : "5672064621", "salario" : 17000.50, "idArea" : 1}``` | Update the employee |
| **Admin** | Employee | **/api/v1/admin/role/\<int:id>** | DELETE | YES | ```{}``` | Delete the employee |
| **Reservation** | Reservation | **/api/v1/reservation/get-available-rooms** | GET | YES | ```{"begin_date" : "2023-01-16", "end_date" : "2023-01-18"}``` | Get the available rooms for reservation |
| **Reservation** | Reservation | **/api/v1/reservation** | GET | YES | ```{}``` | Get all the reservations |
| **Reservation** | Reservation | **/api/v1/reservation?active=true** | GET | YES | ```{}``` | Get all the active reservations |
| **Reservation** | Reservation | **/api/v1/reservation** | POST | YES | ```{ "begin_date" : "2023-04-16", "end_date" : "2023-04-19", "room_id" : 1003, "client_id": 1 }``` | Register a new reservation |
| **Ticket** | Ticket | **/api/v1/ticket** | GET | YES | ```{}``` | Get  all the tickets |
| **Ticket** | Ticket | **/api/v1/ticket** | POST | YES | ```{"reservation_id" : 1}``` | Create a new ticket |


