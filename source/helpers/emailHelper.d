module helpers.emailHelper;

import vibe.d;
import vibemail.email;
import std.exception;
import std.string;
import entity.smtpsettings;

class EmailHelper
{    
    private SMTPSettings smtpSettings;
    private EmailIdentity sender;

    private string messagePlainText;
    private string messageHTML;


    this(ref SMTPSettings smtpSettings) @safe
    {
        enforce(smtpSettings.host != "", "Please set a valid SMTPHost");
        enforce(smtpSettings.port > 0, "Please set a valid SMTPPort");

        this.smtpSettings = smtpSettings;
        this.messagePlainText = "";
        this.messageHTML = "";
    }

    public void setMessagePlainText(string message) @safe
    {
        this.messagePlainText = message;
    }

    public void setMessageHTML(string message) @safe
    {
        this.messageHTML = message;
    }

    public void sendEmail(
        string subject,
        EmailIdentity sender,
        EmailIdentity[] recipients
    ) @trusted {
        enforce(recipients.length > 0, "You must provide at least one recipient");

        auto settings = new SMTPClientSettings(this.smtpSettings.host, this.smtpSettings.port);
        settings.authType = SMTPAuthType.plain;
        settings.connectionType = SMTPConnectionType.plain;
        //settings.connectionType = SMTPConnectionType.startTLS;
        //settings.tlsValidationMode = TLSPeerValidationMode.requireCert;
        
        if ((this.smtpSettings.username != "") && (this.smtpSettings.password != "")) {
            settings.username = this.smtpSettings.username;
            settings.password = this.smtpSettings.password;
        }

        Mail email = new Mail;
        email.headers["Date"] = Clock.currTime().toRFC822DateTimeString();
        email.headers["Subject"] = subject;
        email.headers["Sender"] = sender.getName();
        email.headers["From"] = sender.getNameAndEmail();

        if ((this.messagePlainText != "") && (this.messageHTML != "")) {
            email.setContent(
                mailMixed(
                    mailRelated(
                        mailAlternative(
                            mailText(this.messagePlainText),
                            mailHtml(this.messageHTML) // make sure the html comes last, else the email client won't show it by default
                        )
                    )
                )
            );            
        } else if (this.messagePlainText != "") {
            email.bodyText = this.messagePlainText;
        } else {
            throw new Exception("When sending an HTML email, you must supply both plain text and html text message versions");           
        }

        /*
        email.setContent(
            mailMixed(
                mailRelated(
                    mailAlternative(
                        mailText(messagePlainText),
                        mailHtml("<html><body><center>asdfasdfasdf</center></body></html>") // make sure the html comes last, else the email client won't show it by default
                    )
                    //mailInlineImage(File("app-store.png","rb"), "image/png", "app-store.png@01D0FABA.4ECEA150", "Apple's App Store"),
                ),
                //mailAttachment(File("test.png","rb"),"image/png","image.png"),
                mailAttachment(cast(immutable(ubyte[]))"Hello World!","plain/text","text.txt")
            )
        );
        // End
        */

        foreach(recipient; recipients) {
            email.headers["To"] = recipient.getNameAndEmail();
            sendMail(settings, email);
        }
    }


}

class EmailIdentity
{
    protected string name;
    protected string email;

    this(string email, string name = "") @safe
    {
        enforce(email != "", "You must supply an email address");        
        
        this.email = email;
        this.name = name;
    }

    public string getName() @safe
    {
        return this.name;
    }

    public string getEmail() @safe
    {
        return this.email;
    }

    public string getNameAndEmail() @safe
    {
        if (this.name != "") {
            return format("\"%s\" <%s>", this.name, this.email); 
        } else {
            return this.email;
        }
    }
}
