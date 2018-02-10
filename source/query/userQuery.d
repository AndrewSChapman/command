module query.user;

import std.typecons;
import std.variant;
import std.conv;
import std.exception;
import std.stdio;
import std.string;

import query.abstractquery;
import relationaldb.all;
import entity.profile;
import entity.user;

class UserQuery : AbstractQuery
{
    this(RelationalDBInterface relationalDb) @safe
    {
        super(relationalDb);
    }

    public bool userExistsById(ulong userId) @trusted
    {
        enforce(userId > 0, "UserId must be greater than 0");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    usr
                WHERE
                    usrId = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,
            variantArray(userId)
        );

        return (numRows > 0);
    }
 
    public bool userExistsByEmail(string emailAddress) @trusted
    {
        enforce(emailAddress.length > 5, "Please supply a valid email address");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    usr
                WHERE
                    email = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,  variantArray(emailAddress)
        );

        return (numRows > 0);
    }

    public bool userExistsByUsername(string username) @trusted
    {
        enforce(username.length > 1, "Please supply a valid username");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    usr
                WHERE
                    username = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,  variantArray(username)
        );

        return (numRows > 0);
    }    

    public User getUserByEmail(in string emailAddress) @trusted
    {
        enforce(emailAddress != "", "Please supply a valid email address");

        string sql = "
                SELECT
                    u.usrId, u.usrType, u.username, u.email, u.firstName, u.lastName, u.password as passwordHash, newPasswordPin, 
                        deleted, numLoginAttempts, COALESCE(UNIX_TIMESTAMP(lastLoginAttempt), 0) as lastLoginAttempt, numPinAttempts
                FROM
                    usr u
                WHERE
                    u.email = ?
            ";

        auto user = this.relationalDb.loadRow!User(
            sql,
            variantArray(emailAddress)
        );            

        return user;
    }

    public User getUserByUsername(in string username) @trusted
    {
        enforce(username != "", "Please supply a valid username");

        string sql = `
                SELECT
                    u.usrId, u.usrType, u.username, u.email, u.firstName, u.lastName, u.password as passwordHash, newPasswordPin, deleted, numLoginAttempts, COALESCE(UNIX_TIMESTAMP(lastLoginAttempt), 0) as lastLoginAttempt, numPinAttempts
                FROM
                    usr u
                WHERE
                    u.username = ?
            `;

        auto user = this.relationalDb.loadRow!User(
            sql,
            variantArray(username)
        );            

        return user;
    }    

    public User getUserById(ulong usrId) @trusted
    {
        assert(usrId > 0, "Please supply a valid usrId");
        
        string sql = `
                SELECT
                    u.usrId, u.usrType, u.email, u.username, u.firstName, u.lastName, u.password as passwordHash, newPasswordPin, deleted, numLoginAttempts, COALESCE(UNIX_TIMESTAMP(lastLoginAttempt), 0) as lastLoginAttempt, numPinAttempts
                FROM
                    usr u
                WHERE
                    u.usrId = ?
            `;

        auto user = this.relationalDb.loadRow!User(
            sql,
            variantArray(usrId)
        );            

        return user;
    }

    public Profile getProfileByUserId(ulong usrId) @trusted
    {
        assert(usrId > 0, "Please supply a valid usrId");
        
        string sql = `
                SELECT
                    u.usrId, u.username, u.email, u.firstName, u.lastName, u.usrType, u.deleted
                FROM
                    usr u
                WHERE
                    u.usrId = ?
            `;

        auto profile = this.relationalDb.loadRow!Profile(
            sql,
            variantArray(usrId)
        );            

        return profile;
    }

    public Profile[] getList(uint pageNo = 0, uint usrType = 999, string searchTerm = "", bool showDeleted = false) @trusted
    {
        string sql = `
                SELECT
                    u.usrId, u.username, u.email, u.firstName, u.lastName, u.usrType, u.deleted
                FROM
                    usr u
                WHERE
                    1 = 1
            `;

        auto params = variantArray();

        if (usrType < 99) {
            sql ~= `AND usrType = ? `;
            params ~= Variant(usrType);
        }

        if (searchTerm != "") {
            sql ~= format(`
                AND (
                    username LIKE ? OR firstname LIKE ? OR lastname LIKE ? 
                )
            `);

            searchTerm = "%" ~ searchTerm ~ "%";

            params ~= Variant(searchTerm);
            params ~= Variant(searchTerm);
            params ~= Variant(searchTerm);
        }

        if (!showDeleted) {
            sql ~= "AND deleted = 0 ";
        }

        this.applyPaging(sql, pageNo);

        auto users = this.relationalDb.loadRows!Profile(
            sql,
            params
        );            

        return users;
    }  
}