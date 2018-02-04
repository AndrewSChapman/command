module entity.profile;

import entity.user;

struct Profile
{
    ulong usrId;
    string username;
    string email;
    string firstName;
    string lastName;
    uint usrType;

    this(User user)
    {
        this.usrId = user.usrId;
        this.username = user.username;
        this.email = user.email;
        this.firstName = user.firstName;
        this.lastName = user.lastName;
        this.usrType = user.usrType;
    }
}