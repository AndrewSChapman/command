module decisionmakers.deleteuser;

import std.exception;
import vibe.vibe;

import validators.all;
import decisionmakers.decisionmakerinterface;
import command.all;
import commands.deleteuser;
import commands.deletetoken;
import helpers.testhelper;
import entity.user;

struct DeleteUserFacts
{
    bool userToDeleteExists;
    bool userToDeleteAlreadyDeleted;
    bool userToDeleteIsLastAdminUser;
    UserType loggedInUsrType;
    UserType usrToDeleteUsrType;
    ulong userToDeleteId;
    ulong loggedInUserId;
    bool hardDelete;
    string tokenCode;
}

class DeleteUserDM : DecisionMakerInterface
{
    private DeleteUserFacts facts;
    
    public this(ref DeleteUserFacts facts) @safe
    {
        enforce(facts.userToDeleteExists, "The user you which to delete does not seem to exist.");

        enforce(!facts.userToDeleteAlreadyDeleted || (facts.loggedInUsrType == UserType.ADMIN && facts.hardDelete), 
            "The user you wish to delete has already been deleted");

        enforce(facts.usrToDeleteUsrType != UserType.ADMIN || !facts.userToDeleteIsLastAdminUser, 
            "You may not delete the last system administrator");

        enforce(facts.usrToDeleteUsrType == UserType.GENERAL || (facts.userToDeleteId != facts.loggedInUserId), 
            "You may not delete your own ADMIN user account");

        enforce(facts.loggedInUsrType == UserType.ADMIN || (facts.userToDeleteId == facts.loggedInUserId),
            "You do not have permission to delete a user account different to your own");

        enforce(!facts.hardDelete || facts.loggedInUsrType == UserType.ADMIN, "Only an Admin may perform a hard delete");

        enforce(facts.tokenCode != "" || (facts.loggedInUsrType == UserType.ADMIN && (facts.userToDeleteId != facts.loggedInUserId)),
            "A token code must be provided when a general user is issueing the delete command");

        (new PositiveNumber!ulong(facts.userToDeleteId, "userToDeleteId"));
        (new PositiveNumber!ulong(facts.loggedInUserId, "loggedInUserId"));
        
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {
        auto command = new DeleteUserCommand(
            this.facts.userToDeleteId,
            this.facts.loggedInUserId,
            this.facts.hardDelete
        );

        commandList.append(command, typeid(DeleteUserCommand));

        auto deleteTokenCommand = new DeleteTokenCommand(
            facts.tokenCode,
            facts.userToDeleteId,
            true
        );

        commandList.append(deleteTokenCommand, typeid(DeleteTokenCommand));
    }
}

unittest {
    // Test passing facts
    DeleteUserFacts[] passingFactsArray;

    // General user can delete themselves
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.GENERAL, UserType.GENERAL, 2, 2, false, "MYTOKENCODE");

    // Admin can soft delete other users
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.GENERAL, 2, 1, false, "MYTOKENCODE");
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.ADMIN, 2, 1, false, "MYTOKENCODE");

    // Admin can hard delete other users
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.GENERAL, 2, 1, true, "MYTOKENCODE");
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.ADMIN, 2, 1, true, "MYTOKENCODE");

    // Admin can hard delete an already soft deleted user
    passingFactsArray ~= DeleteUserFacts(true, true, false, UserType.ADMIN, UserType.GENERAL, 2, 1, true, "MYTOKENCODE");

    // Admin does't need the token code
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.ADMIN, 2, 1, false, "");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(DeleteUserDM, DeleteUserFacts)(facts, 2, false);
    }

    
    // Test failing facts
    DeleteUserFacts[] failingFactsArray;

    // User doesn't exist
    failingFactsArray ~= DeleteUserFacts(false, false, false, UserType.ADMIN, UserType.ADMIN, 2, 1, false, "MYTOKENCODE");
    
    // User is already deleted
    failingFactsArray ~= DeleteUserFacts(true, true, false, UserType.ADMIN, UserType.ADMIN, 2, 1, false, "MYTOKENCODE");

    // General user cannot hard delete themselves
    passingFactsArray ~= DeleteUserFacts(true, false, false, UserType.GENERAL, UserType.GENERAL, 2, 2, true, "MYTOKENCODE");

    // Admin may not delete last admin user
    failingFactsArray ~= DeleteUserFacts(true, false, true, UserType.ADMIN, UserType.ADMIN, 2, 1, false, "MYTOKENCODE");

    // General user cannot delete other users
    failingFactsArray ~= DeleteUserFacts(true, false, false, UserType.GENERAL, UserType.GENERAL, 2, 1, false, "MYTOKENCODE");

    // General user cannot hard delete themselves
    failingFactsArray ~= DeleteUserFacts(true, false, false, UserType.GENERAL, UserType.GENERAL, 2, 2, true, "MYTOKENCODE");

    // Admin cannot delete themselves (soft OR hard)
    failingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.ADMIN, 2, 2, false, "MYTOKENCODE");
    failingFactsArray ~= DeleteUserFacts(true, false, false, UserType.ADMIN, UserType.ADMIN, 2, 2, true, "MYTOKENCODE");

    // TokenCode is missing
    failingFactsArray ~= DeleteUserFacts(true, false, false, UserType.GENERAL, UserType.GENERAL, 2, 2, false, "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(DeleteUserDM, DeleteUserFacts)(facts, 0, true);    
    } 
}