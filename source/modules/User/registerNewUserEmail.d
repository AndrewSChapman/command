module email.registernewuser;

import mustache;
import std.file;
import std.stdio;

import email.abstractemail;
import helpers.stringsHelper;

class RegisterNewUserEmail : AbstractEmail
{
    private string username;
    private string firstName;
    private string email;
    
    public this(in ref string username, in ref string firstName, in ref string email)
    {
        super("account/new_user_registration");

        this.username = username;
        this.firstName = firstName;
        this.email = email;
    }

    public void render()
    {
        auto context = new Mustache.Context;
        context["username"] = this.username;
        context["email"] = this.email;
        context["firstName"] = this.firstName;

        super.render(context);
    }
}

/*
unittest {
    auto stringsHelper = new StringsHelper();
    auto email = new RegisterNewUserEmail("Jane", "jane@janedoe.com");
    email.render();

    writeln(stringsHelper.md5(email.getPlainTextEmail()));
    writeln(stringsHelper.md5(email.getHtmlEmail()));

    assert(stringsHelper.md5(email.getPlainTextEmail()) == "99345E86C0A8B5BE9673C2ED9F82CC18");
    assert(stringsHelper.md5(email.getHtmlEmail()) == "6B02BF95C9B8D18A225683FA17AAD9AD");
} */