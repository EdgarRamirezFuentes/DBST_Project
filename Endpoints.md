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

