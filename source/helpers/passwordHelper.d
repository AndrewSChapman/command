module helpers.passwordHelper;

import std.process;
import std.conv;
import std.string;
import std.stdio;

/****************************************************************************
PasswordHelper
Implements Bcrypt Hash and BCrypt verifed methods via shell exec to PHP.
****************************************************************************/
class PasswordHelper
{
    private const BCRYPT_LEVEL = 12;
    
    public string HashBcrypt(string password)
    {
        if (password == "") {
            throw new Exception("Password must not be empty");
        }

        password = escapeShellCommand(password);

        string cmd = "php bcrypt_hash.php " ~ to!string(this.BCRYPT_LEVEL) ~ " " ~ password;
        auto tupleResult = executeShell(cmd);

        uint status = tupleResult[0];
        if (status != 0) {
            throw new Exception("Failed to run bcrypt hash command: " ~ cmd);
        }

        string result = strip(tupleResult[1]);

        return result;
    }

    public bool VerifyBcryptHash(string hash, string password)
    {
        if ((hash == "") || (password == "")) {
            throw new Exception("Hash and password must not be empty");
        }

        hash = escapeShellCommand(hash);
        password = escapeShellCommand(password);

        string cmd = "php bcrypt_verify.php " ~ hash ~ " " ~ password;
        auto tupleResult = executeShell(cmd);

        uint status = tupleResult[0];
        if (status != 0) {
            throw new Exception("Failed to run bcrypt hash command: " ~ cmd);
        }

        string result = strip(tupleResult[1]);

        return result == "1";
    }

    public bool passwordPassesSecurityPolicy(ref string password) {
        return (password.length >= 6);
    }

    public string getPasswordSecurityPolicyText()
    {
        return "Password must be at least 6 characters long";
    }
}