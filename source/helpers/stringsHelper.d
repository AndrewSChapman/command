module helpers.stringsHelper;

import std.random;
import std.conv;
import std.outbuffer;
import std.exception;
import std.string;
import std.stdio;
import std.digest.md;

class StringsHelper
{
    public string generateRandomString(size_t length)
    {
        enforce(length > 0, "Length must be greater than 0");

        const char[62] validChars = [
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i','j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A', 'B', 'C', 'D', 'E', 'F', 'H', 'H', 'I','J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
        ];

        auto buffer = new OutBuffer();
        buffer.reserve(length);

        for (uint i = 0; i < length - 1; i++) {
            buffer.write(validChars[uniform(0, 61)]);
        }

        return buffer.toString();
    }

    public string getFragmentBeforeToken(ref in string stringToGetFragmentFrom, in char token)
    {
        auto tokenPos = indexOf(stringToGetFragmentFrom, token);
        
        if (tokenPos < 0) {
            throw new Exception(format("Token '%c' not found in stringToGetFragmentFrom", token));
        }

        return stringToGetFragmentFrom[0 .. tokenPos];
    }

    public string extractPrefixFromId(ref in string id)
    {
        return this.getFragmentBeforeToken(id, ':');
    }

    public string arrayToString(T)(in T[] items, string glue = ", ")
    {
        string result = "";
        uint counter = 0;

        foreach (item; items) {
            if (counter > 0) {
                result ~= glue ~ to!string(item);
            } else {
                result = to!string(item);
            }
            ++counter;
        }        

        return result;
    }

    public string md5(in string stringToHash)
    {
        auto md5 = new MD5Digest();
        ubyte[] hash = md5.digest(stringToHash);
        return toHexString(hash);
    }
}

unittest {
    auto stringsHelper = new StringsHelper();

    string id = "abc123:12312421142";
    auto prefix = stringsHelper.extractPrefixFromId(id);
    assert(prefix == "abc123");
    assert(stringsHelper.arrayToString!string(["Apple", "Banana", "Pear"]) == "Apple, Banana, Pear");
    assert(stringsHelper.arrayToString!string(["Apple", "Banana", "Pear"], "|") == "Apple|Banana|Pear");
}