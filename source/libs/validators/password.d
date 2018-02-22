module validators.password;

import std.algorithm;
import std.string;

class Password
{
    this(string password, string identifier) @safe {
        if (password.length < 8) {
            throw new Exception(format("%s must be at least 8 characters long", capitalize(identifier)));
        }

        if (!this.strengthOK(password)) {
            throw new Exception(format("%s is too weak", capitalize(identifier)));
        }
    }

    private bool strengthOK(in ref string password) @safe
    {
        int strength = 0;

        if (password.length >= 12) {
            strength += 2;
        } else if(password.length >= 10) {
            strength += 1;
        }

        uint numSymbols = this.countNumberOfSymbols(password);
        if (numSymbols >= 2) {
            strength += 2;
        } else if (numSymbols >= 0) {
            strength += 1;
        }

        uint numUniqueSymbols = this.countUniqueSymbols(password);
        if (numUniqueSymbols < 5) {
            strength -= 5;
        } else if(numUniqueSymbols < 7) {
            strength -= 2;
        } else if(numUniqueSymbols >= 12) {
            strength += 2;
        } else if (numUniqueSymbols >= 9) {
            strength += 1;
        }
        
        return strength >= 3;
    }

    private uint countNumberOfSymbols(in ref string password) @safe
    {
        const char[] validSymbols = ['!', '"', '£', '$', '%', '^', '&', '*', '(', ')', '+', '-', '_', '~', '@', ';', 
            ':', '.', ',', '/', '\\', '|', '\''];

        uint count = 0;
        
        foreach(char character; password) {
            if (validSymbols.canFind(character)) {
                count++;
            }
        }

        return count;
    }

    private uint countUniqueSymbols(in ref string password) @safe
    {
        char[] uniqueSymbols;

        uint count = 0;
        
        foreach(char character; password) {
            if (!uniqueSymbols.canFind(character)) {
                count++;
                uniqueSymbols ~= character;
            }
        }

        return count;
    }
}

unittest {
    // PASSWORDS THAT ARE ACCEPTABLE
    try {
        (new Password("CarrotApple2018", "password"));
    } catch (Exception e) {
        assert(false);
    }

    // PASSWORDS THAT ARE ACCEPTABLE
    try {
        (new Password("Ca^&*bB£", "password"));
    } catch (Exception e) {
        assert(false);
    }    

    // PASSWORDS THAT NOT ACCEPTABLE
    try {
        (new Password("Carrot", "password"));
        assert(false);
    } catch (Exception e) {
        
    }

    try {
        (new Password("CCCCCCCCCCCCCCCCCCCCCCCCCCCC", "password"));
        assert(false);
    } catch (Exception e) {
        
    }

    try {
        (new Password("CAECAECAECAECAECAECAECAECAECAECAECAE", "password"));
        assert(false);
    } catch (Exception e) {
        
    }

    try {
        (new Password("Apple888", "password"));
        assert(false);
    } catch (Exception e) {
        
    }        
}
