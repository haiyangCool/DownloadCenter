//
//  SQLGenerator.swift
//  FMDBDemo
//
//  Created by hyw on 2018/4/26.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/** Query command
    生成需要的SQL语句
    1\Insert
    "INSERT INTO TableName"
    2\Delete
    3\Update
    "UPDATE TableName"
    4\Query
    "SELECT * FROM TableName"
 */
import UIKit

class SQLGenerator: NSObject {

    static let shared = SQLGenerator()
    override init() {
        super.init()
    }
}

/// Generator sql
extension SQLGenerator {
    
    /**
     生成插入数据的SQL
     返回key对应的value集合
     */
    func insertSql(_ tableName:String, insertInfo info:[String:Any]) -> (String,[Any]) {
        
        let insertSql = "INSERT INTO \(tableName) "
        if info.count <= 0 { return ("",[]) }
        var values:[Any] = []
        var insertKeyString = "("
        var insertValueString = "("
        let keys = info.keys.reversed()
        for index in 0..<keys.count {
            
            let key:String = keys[index]
            let value = info[key]
            values.append(value ?? "")
            if index == keys.count-1 {
                insertKeyString.append(key+")")
                insertValueString.append("?)")
            }else {
                insertKeyString.append(key+",")
                insertValueString.append("?,")
            }
        }
        let sql = insertSql + insertKeyString + " VALUES " + insertValueString
        return (sql,values)
    }
    /** 生成删除数据库表数据的SQL
     deleteFilter: 删除满足filer 描述的一条数据
     */
    func deleteSql(_ tableName:String, deleteFilter filter:[String:Any]?) -> String {
        var deleteSql = "DELETE FROM \(tableName)"
        deleteSql = self.whereGenerator(deleteSql, filter: filter)
        return deleteSql
    }
    /** 生成更新数据库表数据的SQL
     updateSpecialItem 需要更新的字段信息
     updateFilter 更新满足filer 描述的所有数据
     */
    func updateSql(_ tableName:String, updateSpecialItem items:[String:Any], updateFilter filter:[String:Any]?) -> (String,[Any]) {
        var updateSql = "UPDATE \(tableName) SET "
        var values:[Any] = []
        
        if items.count <= 0 { return ("",[]) }
        let keys = items.keys.reversed()
        for index in 0..<items.count {
            let key:String = keys[index]
            let value = items[key]
            values.append(value ?? "")
            if index == items.count - 1 {
                updateSql.append(key+" = ?")
            }else {
                updateSql.append(key+" = ?, ")
            }
        }
        updateSql = self.whereGenerator(updateSql, filter: filter)
        return  (updateSql,values)
    }
    /**
        生成查询数据库的SQL
        querySpecialColumItem 要查询的字段名 querySpecialColumItem为空时没查询一行的所有数据
        filter 过滤器字段 查询符合该字段描述的搜优数据
        querySpecialColumItem+filter 查找满足filter的一行的对应querySpecialColumItem字段的数据
     */
    func querySql(_ tableName:String,querySpecialColumItem item:[String]?, queryFilter filter:[String:Any]?) -> String {
        var querySql = "SELECT * FROM \(tableName)"
        if item != nil {
            if !(item?.isEmpty)! {
                var itemsStr = ""
                let itemsCount = (item?.count)!
                
                for index in 0..<itemsCount {
                    if index == itemsCount-1 {
                        itemsStr.append(item![index])
                    }else {
                        itemsStr.append(item![index]+",")
                    }
                }
                querySql = "SELECT \(itemsStr) FROM \(tableName)"
            }
        }
        querySql = self.whereGenerator(querySql, filter: filter)
        return querySql
    }
}

extension SQLGenerator {
    
    /// Where 
    fileprivate func whereGenerator(_ originSql:String, filter:[String:Any]?) -> String {
        var sql = originSql
        if filter == nil || (filter?.count)! <= 0 {
            return originSql
        }else {
            var whereStr = " WHERE "
            let keys = filter?.keys.reversed()
            let keysCount = (keys?.count)!
            
            for index in 0..<keysCount {
                let key:String = keys![index]
                let value:String = filter![key] as! String
                if index == keysCount-1 {
                    whereStr.append(key+value)
                }else {
                    whereStr.append(key+value+" and ")
                }
            }
            sql.append(whereStr)
        }
        return sql
    }
}
