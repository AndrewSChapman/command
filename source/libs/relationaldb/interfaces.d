module relationaldb.interfaces;

import std.variant;
import std.typecons;
import std.stdio;

import mysql;

interface RelationalDBInterface {
    public void execute(string sql, Variant[] params);
    public string getColumnValue(string sql, Variant[] params, uint colNo = 0);
    public int getColumnValueInt(string sql, Variant[] params, uint colNo = 0);
    protected Nullable!(Row) loadUntypedRow(string sql, Variant[] params);
    protected Row[] loadUntypedRows(string sql, Variant[] params);
    public ulong lastInsertId();

    public T loadRow(T)(string sql, Variant[] params)
    {
        auto row = loadUntypedRow(sql, params);
        
        if (row.isNull()) {
            throw new Exception("RelationalDBInterface::loadRow - Query returned an empty row");
        }

        T item;

        try {
            row.toStruct!T(item);   
        } catch (core.exception.RangeError rangeError) {
            writeln("RelationalDBInterface::loadRow - Caught range error: ", rangeError.msg, sql);
        } catch (Exception exception) {
            writeln("RelationalDBInterface::loadRow - Caught general exception: ", exception.msg, sql);
        }        
        
        return item;
    }

    public T[] loadRows(T)(string sql, Variant[] params)
    {
        auto rows = loadUntypedRows(sql, params);
        T[] results;
        
        if (rows.length == 0) {
            return results;
        }

        try {
            foreach(row; rows) {
                T item;
                row.toStruct!T(item);

                results ~= item;
            }
        } catch (core.exception.RangeError rangeError) {
            writeln("RelationalDBInterface::loadRows - Caught range error: ", rangeError.msg, sql);
        } catch (Exception exception) {
            writeln("RelationalDBInterface::loadRows - Caught general exception: ", exception.msg, sql);
        }
        
        return results;
    }        
}