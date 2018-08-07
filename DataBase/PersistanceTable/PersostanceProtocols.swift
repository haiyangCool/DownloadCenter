//
//  PersostanceProtocol.swift
//  FMDBDemo
//
//  Created by hyw on 2018/4/27.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import Foundation
/// 一般她的实现者都是View， 用于收集数据
protocol PersistanceSaveProtocol {
    
    /// 存操作， columnInfo包含了一个表中默认存储的字段， 各个实现者收集自己必要的字段数据 
    func rePresistanceWithColumninfo(columInfo info:Dictionary<String, Any>,tableName name:String) -> [String:Any]
}
/// table create
protocol PersistanceTableProtocol {
    /// 数据库名
    func dataBaseName() -> String
    /// 表明
    func tableName() -> String
    /// 字段
    func tableColumnInfo() -> [String:Any]
    /// primary key
    func primaryKeyName() -> String
    
}
