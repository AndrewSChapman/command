module executors.auth.registeruser;

import std.stdio;
import std.variant;

import relationaldb.all;
import commands.registeruser;
import helpers.helperfactory;
import entity.smtpsettings;
import email.registernewuser;

class RegisterUserProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private RegisterNewUserCommandMetadata meta;
    private HelperFactory helperFactory;
    private SMTPSettings smtpSettings;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        RegisterNewUserCommandMetadata meta,
        ref in SMTPSettings smtpSettings
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
        this.smtpSettings = smtpSettings;
    }

    void handleEvent() {
        this.sendRegistrationEmail();
        ulong usrId = this.createUser();
    }

    private void sendRegistrationEmail()
    {
        auto registerNewUserEmail = new RegisterNewUserEmail(this.meta.userFirstName, this.meta.email);
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