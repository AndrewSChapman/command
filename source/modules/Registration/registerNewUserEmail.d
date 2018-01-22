module email.registernewuser;

import mustache;
import std.file;
import std.stdio;

import email.abstractemail;
import helpers.stringsHelper;

class RegisterNewUserEmail : AbstractEmail
{
    private string firstName;
    private string email;
    
    public this(in string firstName, in string email)
    {
        super("account/new_user_registration");

        this.firstName = firstName;
        this.email = email;
    }

    public void render()
    {
        auto context = new Mustache.Context;
        context["email"] = this.email;
        context["firstName"] = this.firstName;

        super.render(context);
    }
}

unittest {
    auto stringsHelper = new StringsHelper();
    auto email = new RegisterNewUserEmail("Jane", "jane@janedoe.com");
    email.render();

    //writeln(stringsHelper.md5(email.getPlainTextEmail()));
    //writeln(stringsHelper.md5(email.getHtmlEmail()));
    writeln(email.getHtmlEmail());

    assert(stringsHelper.md5(email.getPlainTextEmail()) == "99345E86C0A8B5BE9673C2ED9F82CC18");
    assert(stringsHelper.md5(email.getHtmlEmail()) == "F78EFD54A23141DBAB4FAAF36CBDB32D");
}