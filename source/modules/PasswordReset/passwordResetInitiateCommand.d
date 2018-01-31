module commands.passwordresetinitiate;

import command.abstractcommand;

struct PasswordResetInitiateCommandMetadata
{
    ulong usrId;
    string userFirstName;
    string userLastName;
    string userEmail;
    string newPassword;
}

class PasswordResetInitiateCommand : AbstractCommand!PasswordResetInitiateCommandMetadata
{
    this(
        ulong usrId,
        string userFirstName,
        string userLastName,
        string userEmail,
        string newPassword
    ) @safe {
        PasswordResetInitiateCommandMetadata meta;
        meta.usrId = usrId;
        meta.userFirstName = userFirstName;
        meta.userLastName = userLastName;
        meta.userEmail = userEmail;
        meta.newPassword = newPassword;

        super(meta);
    }
}