module entity.authenticateduser;

import entity.user;

struct AuthenticatedUser
{
    ulong usrId;
    string username;
    string email;
    string firstName;
    string lastName;
    uint usrType;
	string ipAddress;
	string tokenCode; 

    bool isLoggedIn() @property @safe
    {
        return this.usrId > 0;
    }

    bool isAdmin() @property @safe
    {
        return this.isLoggedIn && this.usrType == UserType.ADMIN;
    }

    bool isGeneralUser() @property @safe
    {
        return this.isLoggedIn && this.usrType == UserType.GENERAL;
    }    
}