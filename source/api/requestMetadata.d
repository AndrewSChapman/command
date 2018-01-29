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

struct PasswordResetRequestMeta
{
    string emailAddress;
    string newPassword;
    string newPasswordRepeated;
}

struct PasswordResetCompleteRequestMeta
{
    string emailAddress;
    ulong newPasswordPin;
}

struct UpdateUserRequestMeta
{
    string firstName;
    string lastName;
}

struct ChangePasswordRequestMeta
{
    string existingPassword;
    string newPassword;
    string newPasswordRepeated;
}