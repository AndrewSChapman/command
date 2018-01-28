module commands.passwordresetcomplete;

import commandlib.abstractcommand;

struct PasswordResetCompleteCommandMetadata
{
    ulong usrId;
}

class PasswordResetCompleteCommand : AbstractCommand!PasswordResetCompleteCommandMetadata
{
    this(ulong usrId) @safe
    {
        PasswordResetCompleteCommandMetadata meta;
        meta.usrId = usrId;
        
        super(meta);
    }
}