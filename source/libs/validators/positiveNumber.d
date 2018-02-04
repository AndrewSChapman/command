module validators.positivenumber;

import std.string;
import std.exception;

class PositiveNumber(T)
{
    this(T value, string identifier) {
        static assert((is (T == uint)) || (is (T == ulong)), "PositiveNumber must be either a ulong or uint");

        if (value == 0) {
            throw new Exception(format("%s must be greater than 0", identifier));
        }
    }
}

unittest {
    // TESTS THAT SHOULD PASS
    uint v1 = 1;
    try {
        (new PositiveNumber!uint(v1, "v1"));
    } catch (Exception e) {
        assert(false, "uint value v1 should be fine but is failing");
    }

    ulong v2 = 1;
    try {
        (new PositiveNumber!ulong(v2, "v2"));
    } catch (Exception e) {
        assert(false, "ulong value v2 should be fine but is failing");
    }

    // TESTS THAT SHOULD FAIL
    uint v3 = 0;
    try {
        (new PositiveNumber!uint(v3, "v3"));
        assert(false, "uint value v3 should be failing but is passing");
    } catch (Exception e) {
        
    }

    ulong v4 = 0;
    try {
        (new PositiveNumber!ulong(v4, "v4"));
        assert(false, "ulong value v4 should be failing but is passing");
    } catch (Exception e) {
        
    }    
}