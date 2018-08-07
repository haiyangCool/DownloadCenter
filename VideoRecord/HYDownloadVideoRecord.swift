//
//  HYDownloadVideoRecord.swift
//  DownLoadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit
/// video download status
enum HYDownloadVideoRecordStatus:Int {
    /// download status
    case hyVideoStatusDownloading = 0
    case hyVideoStatusDownloadfaild = 1
    case hyVideoStatusDownloadFinished = 2
    case hyVideoStatusWaitingForDownload = 3
    /// search status
    case hyVideoStatusNotFound = 4
    case hyVideoStatusNative = 5
    case hyVideoStatusPaused
    
}
/// video info
struct HYDownloadVideoRecordInfo {

    var identifier:Int?
    var status:Int?
    var nativeUrl:String?
    var remoteUrl:String?
    var progress:Float?
    
}
class HYDownloadVideoRecord: NSObject {

}
