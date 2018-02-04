module executors.adduser;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import commands.adduser;
import helpers.helperfactory;
import entity.smtpsettings;
import email.registernewuser;

class AddUserExecutor : AbstractExecutor!(AddUserCommand,AddUserCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private AddUserCommandMetadata meta;
    private HelperFactory helperFactory;
    private SMTPSettings smtpSettings;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        CommandInterface command,
        ref in SMTPSettings smtpSettings
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = this.getMetadataFromCommandInterface(command);
        this.smtpSettings = smtpSettings;
    }

    void executeCommand(ref Variant[string] messages) {
        ulong usrId = this.createUser();
        messages["usrId"] = Variant(usrId);
    }

    private ulong createUser() {
        auto passwordHelper = this.helperFactory.createPasswordHelper();
        string hashedPassword = passwordHelper.HashBcrypt(this.meta.password);

        string sql = "
                INSERT INTO usr (usrType, username, email, firstName, lastName, password)
                VALUES (?, ?, ?, ?, ?, ?);
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.usrType,
            this.meta.username,
            this.meta.email,
            this.meta.userFirstName,
            this.meta.userLastName,
            hashedPassword
        ));

        return this.relationalDb.lastInsertId();
    }       
}