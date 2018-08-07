//
//  UserInfoTable.swift
//  FMDBDemo
//
//  Created by hyw on 2018/4/25.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
    持久层Table
    封装了一些增删改查的弱业务逻辑

    注意：filter 的字典添加的value 的要求
    Example ***   age:"<'26'" 或 name:"='why'"  把 条件完整写入
 */
import UIKit
import FMDB

class PersistanceTable: NSObject {

    fileprivate var dataBasePool:FMDBDatabasePool!
    fileprivate var sqlGenerator:SQLGenerator!
    fileprivate var dataBaseIsOpening:Bool = false
    var delegate:PersistanceTableProtocol?
    
    override init() {
        super.init()
        sqlGenerator = SQLGenerator.shared
        dataBasePool = FMDBDatabasePool()
        dataBasePool.delegate = self
    }
    deinit {
        closeDataBase()
    }
}
/// public methods
extension PersistanceTable {
    
    /// insert data
    func insertDataWith(columnInfo:[String:Any]) -> Bool {
        createDataBase()
        let tableName = delegate?.tableName()
        let sql = sqlGenerator.insertSql(tableName!, insertInfo: filterPrimaryKeyColumn(columnInfo: columnInfo))
        return dataBasePool.insertDataWithTableName(name: tableName!, insertCommand: sql.0, insertValues: sql.1)
    }
    /// delete data
    func deleteDataWith(deleteFilter:[String:Any]? = nil) -> Bool {
        createDataBase()
        let tableName = delegate?.tableName()
        let deleteSql = sqlGenerator.deleteSql(tableName!, deleteFilter: deleteFilter)
        return dataBasePool.deleteDataFromTableName(name: tableName!, deleteCommand: deleteSql)
    }
    /// update data overRide == false 时 只更新值不为nil的字段, = true 新的数据覆盖全部
    func updateDataWith(updateItem columnInfo:[String:Any], updateFilter filter:[String:Any]?,shouldOverride overRide:Bool) -> Bool {
        createDataBase()
        let tableName = delegate?.tableName()
        if !overRide {
            /// filter out item.value == nil
            let newItemInfo = filterItemValueEqualNil(itemInfo: filterPrimaryKeyColumn(columnInfo: columnInfo))
            let updateSql = sqlGenerator.updateSql(tableName!, updateSpecialItem: newItemInfo, updateFilter: filter)
            return dataBasePool.updateDataWithTableName(name: tableName!, updateCommand: updateSql.0, updateValues: updateSql.1)
        }
        let updateSql = sqlGenerator.updateSql(tableName!, updateSpecialItem: filterPrimaryKeyColumn(columnInfo: columnInfo), updateFilter: filter)
        print("更新数据 = \(updateSql)")
        return dataBasePool.updateDataWithTableName(name: tableName!, updateCommand: updateSql.0, updateValues: updateSql.1)
    }
    /// query data if condition is nil query user all info
    func queryDataWith(querySpecialItem items:[String]?, queryFilter filter:[String:Any]?) -> [[String:Any]]? {
        createDataBase()
        let tableName = delegate?.tableName()
        let querysql = sqlGenerator.querySql(tableName!, querySpecialColumItem: items, queryFilter: filter)
        return dataBasePool.queryDataWithTableName(name: tableName!, queryCommand: querysql)
    }
}
/// Private methods
extension PersistanceTable {
    
    /// filter out the item data when value=nil 
    fileprivate func filterItemValueEqualNil(itemInfo:[String:Any]) -> [String:Any] {
       
        var tempItemInfo = itemInfo
        for (key,value) in tempItemInfo {
            if Optional(value) == nil || value is NSNull {
                tempItemInfo.removeValue(forKey: key)
            }
        }
        return tempItemInfo
    }
    
    /// open dataBase
    fileprivate func createDataBase() {
    
        if dataBaseIsOpening { return }
        let path = delegate?.dataBaseName()
        let flag = dataBasePool.openDataBaseWith(path: path!)
        if !flag {
            print("dataBase create faild")
            return
        }
        dataBaseIsOpening = true
    }
    /// close dataBase
    fileprivate func closeDataBase() {
        dataBasePool.closeDataBase()
        dataBaseIsOpening = false
    }
    /// reformer tableColumn info
    /**
     "CREATE TABLE IF NOT EXISTS \(UserInfoTableName) (iid INTEGER PRIMARY KEY AUTOINCREMENT,userName TEXT,userSex TEXT,userSignature TEXT,updateTime INTEGER);"
     */
    fileprivate func reformerTableColumn() -> String {
        let tableName = delegate?.tableName()
        let primaryKeyName = delegate?.primaryKeyName()
        let tableColumn = delegate?.tableColumnInfo()
        var createTableSql = ""
        var columnString = "("
        
        if let tableName = tableName, let primaryKeyName = primaryKeyName, let tableColumnInfo = tableColumn {
            for (key,value) in tableColumnInfo {
                if key == primaryKeyName {
                    columnString = columnString + ("\(key) \(value),")
                }else {
                    columnString = columnString + ("\(key) \(value),")
                }
            }
            columnString.removeLast()
            createTableSql = "CREATE TABLE IF NOT EXISTS \(tableName) \(columnString))"
        }
        return createTableSql
    }
    
    /// insert update data filter primary key
    fileprivate func filterPrimaryKeyColumn(columnInfo:[String:Any]) -> [String:Any] {
        var newColumn = columnInfo
        let primaryKeyName = delegate?.primaryKeyName()
        for (key,value) in newColumn {
            if key == primaryKeyName {
                newColumn.removeValue(forKey: key)
            }
        }
        return newColumn
    }
}
/// Protocol methods
extension PersistanceTable:FMDBDatabasePoolDelegate {

    /** create table*/
    func fmdbDatabasePoolCreateTable(_ fmdbDatabasePool: FMDBDatabasePool) -> String {
        
        return reformerTableColumn()
    }
}
