module entity.user;

enum UserType { GENERAL, ADMIN };

struct User
{
    ulong usrId;
    uint usrType;
    string username;
    string email;
    string firstName;
    string lastName;
    string passwordHash;
    ulong newPasswordPin;
    uint deleted;
}