//
//  HYVideoTable.swift
//  DownloadCenter
//
//  Created by hyw on 2018/7/24.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit

class HYVideoTable: PersistanceTable {

    override init() {
        super.init()
        delegate = self
    }
}

extension HYVideoTable: PersistanceTableProtocol {
    func dataBaseName() -> String {
        return "/hyDownloadVideo.sqlite"
    }
    
    func tableName() -> String {
        return "downloadVideo"
    }
    
    func tableColumnInfo() -> [String : Any] {
        return [
                "identifier":"INTEGER PRIMARY KEY AUTOINCREMENT",
                "status":"INTEGET",
                "nativeUrl":"TEXT",
                "remoteUrl":"TEXT",
                "progress":"FLOAT"
                ]
    }
    
    func primaryKeyName() -> String {
        return "identifier"
    }
    
    
}
