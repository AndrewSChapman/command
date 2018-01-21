module entity.user;

struct User
{
    ulong usrId;
    string email;
    string firstName;
    string lastName;
    string passwordHash;
    ulong newPasswordPin;
}