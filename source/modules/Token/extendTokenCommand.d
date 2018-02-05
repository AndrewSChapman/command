module commands.extendtoken;

import command.abstractcommand;

struct ExtendTokenCommandMetadata
{
    string tokenCode;
    string userAgent;
    string ipAddress;
    string prefix;
    ulong usrId;
    uint usrType;
}

class ExtendTokenCommand : AbstractCommand!ExtendTokenCommandMetadata
{
    this(
        in ref string tokenCode,
        in ref string userAgent,
        in ref string ipAddress,
        in ref string prefix,
        in ulong usrId,
        in uint usrType
    ) @safe {
        ExtendTokenCommandMetadata meta;
        meta.tokenCode = tokenCode;
        meta.userAgent = userAgent;
        meta.ipAddress = ipAddress;
        meta.usrId = usrId;
        meta.usrType = usrType;
        meta.prefix = prefix;

        super(meta);
    }
}