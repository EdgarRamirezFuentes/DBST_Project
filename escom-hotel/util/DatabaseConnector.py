import pymssql

class DatabaseConnector():
    """
    Represent a DatabaseConnector

    Attributes:
        username (str): [Username]
        password (str): [Password]
        server (str): [Server]
        database (str): [Database]
    """
    def __init__(self, username : str, password : str, server : str, database : str):
        """
        Initialize a DatabaseConnector object

        Args:
            username (str): [Username]
            password (str): [Password]
            server (str): [Server]
            database (str): [Database]
        """
        self.__username = username
        self.__password = password
        self.__server = server
        self.__database = database
        self.__conn = None

    def connect(self):
        '''
            Get the DB Connection

            Returns:
                Connection object
        '''
        try:
            self.__conn = pymssql.connect(self.__server, self.__username, self.__password, self.__database)
        except Exception as e:
            print(e)
            self.__conn = None
        finally:
            return self.__conn

    def close(self):
        try:
            if self.__conn:
                self.__conn.close()
        except:
            print("No conn")
            pass
