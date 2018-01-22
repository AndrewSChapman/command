module projections.auth.passwordresetinitiate;

import std.stdio;
import std.variant;
import std.random;
import std.conv;
import std.string;

import relationaldb.all;
import decisionmakers.passwordresetinitiate;
import helpers.helperfactory;
import entity.smtpsettings;
import email.passwordreset;

class PasswordResetInitiateProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private PasswordResetInitiateDMMeta meta;
    private HelperFactory helperFactory;
    private SMTPSettings smtpSettings;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        ref in PasswordResetInitiateDMMeta meta,
        ref in SMTPSettings smtpSettings
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
        this.smtpSettings = smtpSettings;
    }

    void handleEvent() {
        ulong newPasswordPin = uniform(10000000, 99999999);
        auto passwordHelper = this.helperFactory.createPasswordHelper();
        string hashedNewPassword = passwordHelper.HashBcrypt(this.meta.newPassword);

        this.setNewPassword(newPasswordPin, hashedNewPassword);
        this.sendResetEmail(this.meta.userFirstName, this.meta.userEmail, newPasswordPin);
    }  

    private void sendResetEmail(string firstName, string email, ulong newPasswordPin)
    {
        auto passwordResetEmail = new PasswordResetEmail(firstName, to!string(newPasswordPin));
        passwordResetEmail.render();
        
        auto emailHelper = this.helperFactory.createEmailHelper(this.smtpSettings);

        emailHelper.setMessagePlainText(passwordResetEmail.getPlainTextEmail());
        emailHelper.setMessageHTML(passwordResetEmail.getHtmlEmail());

        emailHelper.sendEmail(
            "WellRestD Password Reset Request",
            new EmailIdentity("andy@chapmandigital.co.uk"),
            [new EmailIdentity(email)]
        );
    }

    private void setNewPassword(ulong newPasswordPin, string hashedNewPassword)
    {        
        string sql = "
                UPDATE usr SET 
                    newPassword = ?,
                    newPasswordPin = ?
                WHERE usrId = ?;
            ";

        this.relationalDb.execute(sql, variantArray(
            hashedNewPassword,
            newPasswordPin,
            this.meta.usrId
        ));
    }   
}