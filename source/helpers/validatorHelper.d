module helpers.validatorHelper;

import std.exception;
import std.string;
import std.stdio;
import std.conv;
import std.algorithm.searching;
import std.math;

import query.all;
import container;

class ValidatorHelper
{   
    // Rudimentary email address validator
    public bool validateEmailAddress(string emailAddress) @safe
    {
        if (emailAddress == "") {
            return false;
        }

        // Ensure there is at @ symbol and that the @ symbol is not the first character
        auto atPos = indexOf(emailAddress, "@");
        if (atPos <= 0) {
            return false;
        }

        // Ensure there is not a second @ symbol
        auto atPos2 = indexOf(emailAddress, "@", atPos + 1);
        if (atPos2 > 0) {
            return false;
        }

        // Ensure there is a dot after the the at symbol
        auto dotPos = indexOf(emailAddress, ".", atPos + 2);
        if (dotPos <= 0) {
            return false;
        }

        return true;
    } 
    
    /**
    For a given struct instance of type T, validate that all the required members as defined in the
    required members array have a value set.
    */
    public string[] enforceRequiredFields(T)(T structInstance, in string[] requiredMembers) @trusted
    {
        string[] missingFields;

        foreach (memberName; __traits(allMembers, T)) {
            if (!canFind(requiredMembers, memberName)) {
                continue;
            }

            // How do i get the value of "memberName" from "structInstance"
            auto memberValue = __traits(getMember, structInstance, memberName);

            if (__traits(isIntegral, memberValue)) {
                if (to!long(memberValue) == 0) {
                    missingFields ~= memberName;
                }
            } else if (__traits(isFloating, memberValue)) {
                auto const testValue = to!float(memberValue);
                if ((testValue == 0) || (isNaN(testValue))) {
                    missingFields ~= memberName;
                }
            } else if (typeid(memberValue) == typeid(string)) {
                if (to!string(memberValue) == "") {
                    missingFields ~= memberName;
                }
            } else {
                throw new Exception(format("validateRequiredMembersForStruct - Unhandled member type: %s", typeid(memberValue)));
            }
        }

        return missingFields;
    }
}

class ValidationException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe
    {
        super("Validation Exception - " ~ msg, file, line);
    }
}

unittest {
    auto validatorHelper = new ValidatorHelper();

    // Test correct email addresses
    assert(validatorHelper.validateEmailAddress("andy@andychapman.net"));
    assert(validatorHelper.validateEmailAddress("a@a.co"));

    // Test incorrect email addresses
    assert(validatorHelper.validateEmailAddress("") == false);
    assert(validatorHelper.validateEmailAddress("a") == false);
    assert(validatorHelper.validateEmailAddress("a@a") == false);
    assert(validatorHelper.validateEmailAddress("a@.co") == false);
    assert(validatorHelper.validateEmailAddress("apple") == false);
    assert(validatorHelper.validateEmailAddress("apple@") == false);
    assert(validatorHelper.validateEmailAddress("apple@apple") == false);
    assert(validatorHelper.validateEmailAddress("@apple.com") == false);

    // Test required fields validator
    struct TestStruct
    {
        string stringVal;
        int intVal;
        long longVal;
        float floatVal;
        uint uintVal;
        ulong ulongVal;
    }

    TestStruct t;
    t.stringVal = "Andy";
    t.intVal = 5;
    t.longVal = 10;
    t.floatVal = 10.5;
    t.uintVal = 2;
    t.ulongVal = 200000;

    string[] requiredFields = ["stringVal", "intVal", "longVal", "floatVal", "uintVal", "ulongVal"];
    string[] missingFields = validatorHelper.enforceRequiredFields!TestStruct(t, requiredFields);
    assert(missingFields.length == 0);

    TestStruct t2;
    missingFields = validatorHelper.enforceRequiredFields!TestStruct(t2, requiredFields);
    assert(missingFields.length == 6);
}