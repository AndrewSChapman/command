module entity.user;

struct User
{
    ulong usrId;
    uint usrType;
    string email;
    string firstName;
    string lastName;
    string passwordHash;
    ulong newPasswordPin;
}