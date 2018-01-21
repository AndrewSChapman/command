module projections.auth.registeruser;

import std.stdio;
import std.variant;

import relationaldb.all;
import decisionmakers.registeruser;
import helpers.helperfactory;

class RegisterUserProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private RegisterUserDMMeta meta;
    private HelperFactory helperFactory;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        RegisterUserDMMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
    }

    void handleEvent() {
        ulong usrId = this.createUser();
    }

    private ulong createUser() {
        auto passwordHelper = this.helperFactory.createPasswordHelper();
        string hashedPassword = passwordHelper.HashBcrypt(this.meta.password);

        string sql = "
                INSERT INTO usr (email, firstName, lastName, password)
                VALUES (?, ?, ?, ?);
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.email,
            this.meta.userFirstName,
            this.meta.userLastName,
            hashedPassword
        ));

        return this.relationalDb.lastInsertId();
    }       
}