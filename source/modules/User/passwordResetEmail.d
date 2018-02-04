module email.passwordreset;

import mustache;
import std.file;
import std.stdio;

import email.abstractemail;
import helpers.stringsHelper;

class PasswordResetEmail : AbstractEmail
{
    private string firstName;
    private string pin;
    
    public this(in string firstName, in string pin)
    {
        super("account/password_reset");

        this.firstName = firstName;
        this.pin = pin;
    }

    public void render()
    {
        auto context = new Mustache.Context;
        context["pin"] = this.pin;
        context["firstName"] = this.firstName;

        super.render(context);
    }
}

/*
unittest {
    auto stringsHelper = new StringsHelper();
    auto email = new PasswordResetEmail("Andy", "111222333");
    email.render();
    assert(stringsHelper.md5(email.getPlainTextEmail()) == "C4BBF284C2CC442B3BE215BA8E0C488A");
    assert(stringsHelper.md5(email.getHtmlEmail()) == "82366FB9250F62A50179A7573DC453BE");
} */