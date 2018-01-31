module commands.login;

import command.abstractcommand;

struct LoginCommandMetadata
{
    ulong usrId;
    string userAgent;
    string ipAddress;
    string prefix;
}

class LoginCommand : AbstractCommand!LoginCommandMetadata
{
    this(
        ulong usrId,
        string userAgent,
        string ipAddress,
        string prefix
    ) @safe {
        LoginCommandMetadata meta;
        meta.usrId = usrId;
        meta.userAgent = userAgent;
        meta.ipAddress = ipAddress;
        meta.prefix = prefix;
        
        super(meta);
    }
}