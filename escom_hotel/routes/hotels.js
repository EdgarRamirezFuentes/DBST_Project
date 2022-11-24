const express = require('express');
const router = express.Router();
const sql = require('mssql');
const { ExecuteSQL } = require('../utils/db-operations');



/* GET users listing. */
router.get('/', async (req, res) => {
  // TEST SQL SERVER CONNECTION
  const s = await ExecuteSQL("SELECT * FROM HOTELS");
  if(s.recordset.length > 0){
    res.status(200).json(s.recordset);
  }
  else{
    res.json({message: "No se encontraron hoteles"});
  }
});



module.exports = router;
