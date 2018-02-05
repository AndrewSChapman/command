module commands.deletetoken;

import command.abstractcommand;

struct DeleteTokenCommandMetadata
{
    string tokenCode;
    ulong usrId;
    bool deleteAllUserTokens;
}

class DeleteTokenCommand : AbstractCommand!DeleteTokenCommandMetadata
{
    this(
        in ref string tokenCode,
        in ref ulong usrId,
        in bool deleteAllUserTokens
    ) @safe {
        DeleteTokenCommandMetadata meta;
        meta.tokenCode = tokenCode;
        meta.usrId = usrId;
        meta.deleteAllUserTokens = deleteAllUserTokens;

        super(meta);
    }
}