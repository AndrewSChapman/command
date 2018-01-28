module api.requestMetadata;

struct RegisterNewUserRequestMetadata
{
    string userFirstName;
    string userLastName;
    string email;
    string password;
}

struct LoginRequestMetadata
{
    string email;
    string password;
    string prefix;
}