module commands.changeemail;

import command.abstractcommand;

struct ChangeEmailCommandMeta
{
    ulong usrId;
    string emailAddress;
}

class ChangeEmailCommand : AbstractCommand!ChangeEmailCommandMeta
{
    this(in ref ulong usrId, in ref string emailAddress) @safe
    {
        ChangeEmailCommandMeta meta;
        meta.usrId = usrId;
        meta.emailAddress = emailAddress;
        
        super(meta);
    }
}