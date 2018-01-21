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

    this(QueryFactory queryFactory) {
        this.queryFactory = queryFactory;
    }    
    
    public PasswordHelper createPasswordHelper()
    {
        return new PasswordHelper();
    }

    public EmailHelper createEmailHelper(ref SMTPSettings smtpSettings)
    {
        return new EmailHelper(smtpSettings);
    }

    public StringsHelper createStringsHelper()
    {
        return new StringsHelper();
    }

    public ValidatorHelper createValidatorHelper()
    {
        return new ValidatorHelper();
    }
}