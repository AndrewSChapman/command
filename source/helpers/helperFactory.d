module helpers.helperfactory;

public import helpers.passwordHelper;
public import helpers.emailHelper;
public import helpers.stringsHelper;
public import helpers.validatorHelper;

import entity.smtpsettings;
import query.factory;

class HelperFactory
{
    private QueryFactory queryFactory;

    this(QueryFactory queryFactory) @safe
    {
        this.queryFactory = queryFactory;
    }    
    
    public PasswordHelper createPasswordHelper() @safe
    {
        return new PasswordHelper();
    }

    public EmailHelper createEmailHelper(ref SMTPSettings smtpSettings) @safe
    {
        return new EmailHelper(smtpSettings);
    }

    public StringsHelper createStringsHelper() @safe
    {
        return new StringsHelper();
    }

    public ValidatorHelper createValidatorHelper() @safe
    {
        return new ValidatorHelper();
    }
}