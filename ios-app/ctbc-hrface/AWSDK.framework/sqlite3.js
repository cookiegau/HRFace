const SQLITE_OK = 0;
const SQLITE_ROW = 100;
const SQLITE_DONE = 101;

/**
 * SQLite3 Database
 * @param {string} path path to database
 * @throws Error error if sqlite3_open_v2 does not return SQLITE_OK
 * @constructor
 */
function SQLite3Database(path){
    this._db = _sqlite3_open(path);
}

/**
 * SQLite3 Statement
 * @param {SQLite3Database} db
 * @param {string} sql
 * @throws Error error if SQLITE_OK is not returned from sqlite3_prepare
 * @constructor
 */
function SQLite3Statement(db, sql) {
    this._db = db;
    this._st = _sqlite3_prepare(db, sql);
}

/**
 * Execute sql
 * @param {string} sql
 * @return {number} return code of sqlite3_exec
 * @throws Error error if SQLITE_OK is not returned from sqlite3_exec
 */
SQLite3Database.prototype.exec = function(sql){
    return _sqlite3_exec(this._db, sql);
}

/**
 * Create a SQL query
 * @param {string} sql the sql
 * @throws Error error if SQLITE_OK is not returned from sqlite3_prepare
 * @return {SQLite3Query}
 */
SQLite3Database.prototype.query = function(sql){
    return new SQLite3Query(this._db, sql);
}

/**
 * Prepare a statement
 * @param {string} sql the sql
 * @throws Error error if SQLITE_OK is not returned from sqlite3_prepare
 * @return {SQLite3Statement}
 */
SQLite3Database.prototype.prepare = function(sql){
    return new SQLite3Statement(this._db, sql);
}

/**
 * Execute insert/update/delete with current binding parameters
 * @return {boolean}
 */
SQLite3Statement.prototype.executeUpdate = function(){
    return this.step() === SQLITE_DONE;
}

/**
 * Calls sqlite3_step to process next cursor in statement
 * @throws Error error if SQLITE_ROW or SQLITE_DONE is not returned from sqlite3_step
 * @return {number} the return code from sqlite3_step
 */
SQLite3Statement.prototype.step = function(){
    return _sqlite3_step(this._st);
}

/**
 * Reset the statement to bind new parameters using sqlite3_reset
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.reset = function(){
    _sqlite3_reset(this._st);
    return this;
}

/**
 * Finalize statement. NOTE: statements get finalized by default via garbage collection
 */
SQLite3Statement.prototype.finalize = function(){
    _sqlite3_finalize(this._st);
}

/**
 * Gets the index of the parameter by name
 * @param {string} name parameter name
 * @return {number} index of parameter
 */
SQLite3Statement.prototype.getBindParameterIndex = function(name){
    return _sqlite3_bind_parameter_index(this._st, name);
}

/**
 * Gets the index of the parameter by name
 * @param {number} index parameter index
 * @return {string} parameter name
 */
SQLite3Statement.prototype.getBindParameterName = function(index){
    return _sqlite3_bind_parameter_name
    (this._st, index);
}

/**
 * Bind null parameter of statement
 * @param {number} col column index
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.bindNull = function(col){
    _sqlite3_bind_null(this._st, col);
    return this;
}

/**
 * Bind text parameter of statement
 * @param {number} col column index
 * @param {string} txt
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.bindText = function(col, txt){
    _sqlite3_bind_text(this._st, col, txt);
    return this;
}

/**
 * Bind int parameter of statement
 * @param {number} col column index
 * @param {number} num
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.bindInt = function(col, num){
    _sqlite3_bind_int(this._st, col, num);
    return this;
}

/**
 * Bind int64 parameter of statement
 * @param {number} col column index
 * @param {number} num
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.bindInt64 = function(col, num){
    _sqlite3_bind_int64(this._st, col, num);
    return this;
}

/**
 * Bind double parameter of statement
 * @param {number} col column index
 * @param {number} num
 * @return {SQLite3Statement}
 */
SQLite3Statement.prototype.bindDouble = function(col, num){
    _sqlite3_bind_double(this._st, col, num);
    return this;
}

/**
 * SQLite3 Query
 * @param {SQLite3Database} db the sqlite3 db instance
 * @param {string} sql the sql
 * @extends SQLite3Statement
 * @constructor
 */
function SQLite3Query(db, sql){
    SQLite3Statement.apply(this, arguments);
}
SQLite3Query.prototype = Object.create(SQLite3Statement.prototype);
SQLite3Query.prototype.constructor = SQLite3Query;

/**
 * Gets next record in cursor
 * @return {boolean} true if there are more records in the query
 */
SQLite3Query.prototype.next = function(){
    return this.step() === SQLITE_ROW;
}

/**
 * Get int value from column
 * @param {number} index column index
 * @return {number} column value
 */
SQLite3Query.prototype.getColumnInt = function(index){
    return _sqlite3_column_int(this._st, index);
}

/**
 * Get int64 value from column
 * @param {number} index column index
 * @return {number} column value
 */
SQLite3Query.prototype.getColumnInt64 = function(index){
    return _sqlite3_column_int64(this._st, index);
}

/**
 * Get double value from column
 * @param {number} index column index
 * @return {number} column value
 */
SQLite3Query.prototype.getColumnDouble = function(index){
    return _sqlite3_column_double(this._st, index);
}

/**
 * Get text value from column
 * @param {number} index column index
 * @return {string} column text
 */
SQLite3Query.prototype.getColumnText = function(index){
    return _sqlite3_column_text(this._st, index);
}

/**
 * @module sqlite3
 */

/**
 * Open new SQLite3 database
 * @param {string} path path to database file
 * @throws Error error if SQLITE_OK is not returned from sqlite3_open_v2
 * @return {SQLite3Database}
 */
module.exports = function(path){
    return new SQLite3Database(path);
};