//
//  FMDBDatabasePool.swift
//  FMDBDemo
//
//  Created by hyw on 2018/2/26.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/**
    Strong / weak logic split
    DataBase 
 
 */
//let FMDB_DataBase_FilePath = "/myApp.sqlite" /// test path

protocol FMDBDatabasePoolDelegate {
    /** create table*/
    func fmdbDatabasePoolCreateTable(_ fmdbDatabasePool:FMDBDatabasePool) -> String
}
import UIKit
import FMDB
final class FMDBDatabasePool: NSObject {

    var delegate:FMDBDatabasePoolDelegate?
    
    fileprivate var dataBaseQueue:FMDatabaseQueue?
    override init() {
        super.init()
    }
}

/**Public methods
  __insert delete update query
 */
extension FMDBDatabasePool {

    /** open dataBase*/
    func openDataBaseWith(path:String) -> Bool {
        
        let dataBasePath = self.dataBaseFilePath(path: path)
        dataBaseQueue = openDataBase(path: dataBasePath)
        if dataBaseQueue == nil { return false }
        return true
    }
    /** close dataBase*/
    func closeDataBase() {
        dataBaseQueue?.close()
        dataBaseQueue = nil
    }
    /** Insert data
        if table is not exit ,than create thsi table with tableName,and insert data……
     */
    func insertDataWithTableName(name:String,insertCommand command:String, insertValues values:[Any]) -> Bool {
        var flag = false
        if !isTableExistWithTableName(name) {
            if self.delegate != nil {
                let createTableSql =  self.delegate?.fmdbDatabasePoolCreateTable(self)
                flag = self.createTable(createTableSql!)
            }
        }
        dataBaseQueue?.inTransaction({ (db, rollBack) in
            flag = db.executeUpdate(command, withArgumentsIn: values)
        })
        return flag
    }
    
    /**
     delete data if table exits
     else return delete false flag
     */
    func deleteDataFromTableName(name:String,deleteCommand command:String) -> Bool {
        
        var flag = false
        if isTableExistWithTableName(name) {
            dataBaseQueue?.inTransaction { (db, rollBack) in
                flag = db.executeUpdate(command, withArgumentsIn: [0])
            }
        }
        return flag
    }
    
    /**
     updata data if table exits
     else return update false flag
     */
    func updateDataWithTableName(name:String,updateCommand command:String,updateValues values:[Any]) -> Bool {
        var flag = false
        if isTableExistWithTableName(name) {
            dataBaseQueue?.inTransaction({ (db, rollBack) in
                flag = db.executeUpdate(command, withArgumentsIn: values)
            })
        }
        return flag
    }

    /**
     query data if table exits
     else return query false flag
     */
    func queryDataWithTableName(name:String,queryCommand command:String) -> [[String:Any]]? {
        
        var queryResult:[[String:Any]]? = []

        var result:FMResultSet? = nil
        if isTableExistWithTableName(name) {
            dataBaseQueue?.inTransaction({ (db, rollBack) in
                result = db.executeQuery(command, withArgumentsIn: [0])
                if result != nil {
                    while (result?.next())! {
                        let dic = result?.resultDictionary
                        queryResult?.append(dic as! [String : Any])
                    }
                }
                result?.close()
            })
        }
        return queryResult
    }
}

/** Private methods
 */
extension FMDBDatabasePool {
    
    /** Opten database*/
    fileprivate func openDataBase(path:String) -> FMDatabaseQueue? {
        dataBaseQueue = FMDatabaseQueue.init(path: path)
        return dataBaseQueue
    }
    
    /** DataBase file path*/
    fileprivate func dataBaseFilePath(path:String) -> String {
        var basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        basePath?.append(path)
        return basePath!
    }
    /** Create new Table*/
    fileprivate func createTable(_ sqlSentence:String) -> Bool {
        
        if sqlSentence.isEmpty {
            print("the create table sql is rong")
            return false
        }
        var result:Bool = false
        dataBaseQueue?.inDatabase { (db) in
          result = db.executeStatements(sqlSentence)
        }
        if result {
            print("create table success")
        }else {
            print("create table faild")
        }
        return result
    }
    /** isExit table*/
    fileprivate func isTableExistWithTableName(_ tableName:String) -> Bool {
        var isExist = false
        dataBaseQueue?.inDatabase { (db) in
            isExist = db.tableExists(tableName)
        }
        if isExist {
//            print("this table is exist")
        }else {
            print("this table is not exist")
        }
        return isExist
    }
    /** close dataBase*/
    fileprivate func closeDataBasePool() {
        
        dataBaseQueue?.close()
        dataBaseQueue = nil
    }
}
