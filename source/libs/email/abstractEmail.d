module email.abstractemail;

import mustache;

alias MustacheEngine!(string) Mustache;

class AbstractEmail
{
    private string templateName;
    private string plainTextEmail;
    private string htmlEmail;

    protected this(string templateName)
    {
        this.templateName = templateName;
    }

    protected string getTemplatePath()
    {
        return "emailtemplates/" ~ this.templateName;
    }

    protected void render(Mustache.Context context)
    {
        Mustache mustache;

        const string templatePath = this.getTemplatePath();
        this.plainTextEmail = mustache.render(templatePath ~ ".txt", context);
        this.htmlEmail = mustache.render(templatePath ~ ".html", context);
    }

    public string getPlainTextEmail()
    {
        return this.plainTextEmail;
    }

    public string getHtmlEmail()
    {
        return this.htmlEmail;
    }    
}