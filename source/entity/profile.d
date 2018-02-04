module entity.profile;

import entity.user;

struct Profile
{
    string email;
    string firstName;
    string lastName;
    uint usrType;

    this(User user)
    {
        this.email = user.email;
        this.firstName = user.firstName;
        this.lastName = user.lastName;
        this.usrType = user.usrType;
    }
}