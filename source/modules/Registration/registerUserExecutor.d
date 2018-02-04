module executors.auth.registeruser;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import commands.registeruser;
import helpers.helperfactory;
import entity.smtpsettings;
import email.registernewuser;

class RegisterUserExecutor : AbstractExecutor!(RegisterUserCommand,RegisterNewUserCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private RegisterNewUserCommandMetadata meta;
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

    void executeCommand() {
        this.sendRegistrationEmail();
        ulong usrId = this.createUser();
    }

    private void sendRegistrationEmail()
    {
        auto registerNewUserEmail = new RegisterNewUserEmail(this.meta.username, this.meta.userFirstName, this.meta.email);
        registerNewUserEmail.render();

        auto emailHelper = this.helperFactory.createEmailHelper(this.smtpSettings);

        emailHelper.setMessagePlainText(registerNewUserEmail.getPlainTextEmail());
        emailHelper.setMessageHTML(registerNewUserEmail.getHtmlEmail());

        emailHelper.sendEmail(
            "Welcome To CommanD",
            new EmailIdentity("andy@chapmandigital.co.uk"),
            [new EmailIdentity(this.meta.email)]
        );        
    }

    private ulong createUser() {
        auto passwordHelper = this.helperFactory.createPasswordHelper();
        string hashedPassword = passwordHelper.HashBcrypt(this.meta.password);

        string sql = "
                INSERT INTO usr (usrType, username, email, firstName, lastName, password)
                VALUES (0, ?, ?, ?, ?, ?);
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.username,
            this.meta.email,
            this.meta.userFirstName,
            this.meta.userLastName,
            hashedPassword
        ));

        return this.relationalDb.lastInsertId();
    }       
}