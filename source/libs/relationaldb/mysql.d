module relationaldb.mysql;

import std.conv;
import std.variant;
import std.typecons;
import std.array;

import relationaldb.interfaces;
import mysql;

class MySQLRelationalDB : RelationalDBInterface {
    private Connection conn;
    private const string classID = "MySQLRelationalDB";

    this(Connection conn) {
        this.conn = conn;
    }    

    public void execute(string sql, Variant[] params) {
        Prepared prepared = prepare(this.conn, sql);
        prepared.setArgs(params);
        prepared.exec();
    }

    public string getColumnValue(string sql, Variant[] params, uint colNo) {
        Prepared prepared = prepare(this.conn, sql);
        prepared.setArgs(params);

        auto row = prepared.queryRow();

        if (row.isNull()) {
            throw new Exception(this.classID ~ "::getColumnValue - Query returned an empty row");
        }

        auto value = row[colNo].toString();

        return value;        
    }

    public int getColumnValueInt(string sql, Variant[] params, uint colNo = 0) {
        auto value = this.getColumnValue(sql, params, colNo);
        return to!int(value);
    }

    protected Nullable!(Row) loadUntypedRow(string sql, Variant[] params)
    {
        Prepared prepared = prepare(this.conn, sql);
        prepared.setArgs(params);

        auto row = prepared.queryRow();

        if (row.isNull()) {
            throw new Exception(this.classID ~ "::loadUntypedRow - Query returned an empty row");
        }

        return row;
    }

    protected Row[] loadUntypedRows(string sql, Variant[] params)
    {
        Prepared prepared = prepare(this.conn, sql);
        prepared.setArgs(params);

        try {
            auto rows = prepared.query().array();
            return rows;
        } catch (MySQLNoResultRecievedException exception) {
            Row[] results;
            return results;
        }
    }    

    public ulong lastInsertId()
    {
        return this.conn.lastInsertID();        
    }
}