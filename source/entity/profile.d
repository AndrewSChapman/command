module entity.profile;

import entity.user;

struct Profile
{
    string email;
    string firstName;
    string lastName;

    this(User user)
    {
        this.email = user.email;
        this.firstName = user.firstName;
        this.lastName = user.lastName;
    }
}