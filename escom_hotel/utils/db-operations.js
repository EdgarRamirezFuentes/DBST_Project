const  sql = require('mssql');

// DB setup
const dbConfig = {
    user: 'sa',
    password: 'catDBST2022Ñ',
    server: 'mssql',
    database: 'ESCOM_HOTEL',
    options: {
        encrypt: true,
        enableArithAbort: true,
        trustServerCertificate: true,
    }
};

const conn = new sql.ConnectionPool(dbConfig);

// DB operations
function ExecuteSQL(query) {
    return new Promise((resolve, reject) => {
        conn.connect().then(pool => {
            return pool.request().query(query);
        }).then(result => {
            resolve(result);
        }).catch(err => {
            reject(err);
        });
    });
}

module.exports = {
    ExecuteSQL,
};