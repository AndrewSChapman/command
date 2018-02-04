module commands.extendtoken;

import command.abstractcommand;

struct ExtendTokenCommandMeta
{
    string tokenCode;
    string userAgent;
    string ipAddress;
    string prefix;
    ulong usrId;
    uint usrType;
}

class ExtendTokenCommand : AbstractCommand!ExtendTokenCommandMeta
{
    this(
        in ref string tokenCode,
        in ref string userAgent,
        in ref string ipAddress,
        in ref string prefix,
        in ulong usrId,
        in uint usrType
    ) @safe {
        ExtendTokenCommandMeta meta;
        meta.tokenCode = tokenCode;
        meta.userAgent = userAgent;
        meta.ipAddress = ipAddress;
        meta.usrId = usrId;
        meta.usrType = usrType;

        super(meta);
    }
}