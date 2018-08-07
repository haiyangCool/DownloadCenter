//
//  HYVideoDownloadDataCenter.swift
//  DownLoadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/// Download video data center
/// Insert\update\delete download video info
/// 使用字典字段单独存储对于后期维护会十分困难，需要对record进行协议处理，使dataBase和view都能理解
import UIKit

class HYVideoDownloadDataCenter: NSObject {

    fileprivate var videoTable:HYVideoTable?
    override init() {
        super.init()
        videoTable = HYVideoTable.init()
        
    }
}

//MARK-Public methods
extension HYVideoDownloadDataCenter {
    
    //FIXME:- wiating fix
    //MARK:-
    //video status with remoteUrl
    func videoStatusWithRemoteUrl(_ url:URL) -> HYDownloadVideoRecordStatus {
        
        let videoList = videoTable?.queryDataWith(querySpecialItem: ["status"], queryFilter: ["remoteUrl":"='\(url.absoluteString)'"])
        if videoList == nil || (videoList?.count)! <= 0 {
            return .hyVideoStatusNotFound
        }
        let rowStatus:Int = videoList![0]["status"] as! Int
        return HYDownloadVideoRecordStatus(rawValue: rowStatus)!
    }
    
    // native Url transfor remote url
    func nativeUrlWithRemoteUrl(_ url:URL) -> URL? {
        
        let videoList = videoTable?.queryDataWith(querySpecialItem: ["nativeUrl"], queryFilter: ["remoteUrl":"='\(url.absoluteString)'"])
        if videoList == nil || (videoList?.count)! <= 0 {
            return nil
        }
        let nativeUrlStr:String = videoList![0]["nativeUrl"] as! String
        return URL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]+"/\(nativeUrlStr)")
        /// NSSearchPathForDirectoriesInDomains 不会在结尾加上(/),所以在返回播放地址时手动加上（/）
    }
    
    // videoRemoteUrlRecord list  by video status
    func recordRemoteUrlListWithStatus(_ statue:HYDownloadVideoRecordStatus) -> [URL]? {
        
        let videoList = videoTable?.queryDataWith(querySpecialItem: ["remoteUrl"], queryFilter: ["status":"='\(statue.rawValue)'"])
        if videoList == nil || (videoList?.count)! <= 0 {
            return nil
        }
        var urlList:[URL] = []
        for videoInfo in videoList! {
            urlList.append(URL.init(string: videoInfo["remoteUrl"] as! String)!)
        }
        return urlList
    }
    // videoRecord list  by video status
    func recordListWithStatus(_ statue:HYDownloadVideoRecordStatus) -> [[String:Any]]? {
        
        let recordList = videoTable?.queryDataWith(querySpecialItem: nil, queryFilter: ["status":"='\(statue.rawValue)'"])
        if recordList == nil || (recordList?.count)! <= 0 {
            return nil
        }
        return recordList
    }
    // video record with remote Url
    func recordWithRemoteUrl(_ url:URL) -> [String:Any]? {
        let record = videoTable?.queryDataWith(querySpecialItem: nil, queryFilter: ["remoteUrl" : "='\(url.absoluteString)'"])
        if record == nil || (record?.count)! <= 0 {
            return nil
        }
        return record?[0]
    }
    // MARK -
    /// update video status with remote url
    func updateVideoStatus(_ statue:HYDownloadVideoRecordStatus,remoteUrl url:URL) {
        var flag:Bool?
        
        let record = videoTable?.queryDataWith(querySpecialItem: nil, queryFilter: ["remoteUrl":"='\(url.absoluteString)'"])
        if record == nil || (record?.isEmpty)! {
           flag = videoTable?.insertDataWith(columnInfo: ["status":statue.rawValue,"remoteUrl":"\(url.absoluteString)"])
        } else {
           flag = videoTable?.updateDataWith(updateItem: ["status":statue.rawValue], updateFilter: ["remoteUrl":"='\(url.absoluteString)'"], shouldOverride: false)
        }
        print("update video flag=\(String(describing: flag)) \(statue)")
    }
    
    /// update video  remote url and native url and status
    func updateVideoStatue(_ statue:HYDownloadVideoRecordStatus,remoteUrl url:URL, nativeUrl nUrl:URL) {
        var flag:Bool?
        
        let record = videoTable?.queryDataWith(querySpecialItem: nil, queryFilter: ["remoteUrl":"='\(url.absoluteString)'"])
        
        if record == nil || (record?.isEmpty)! {
            flag = videoTable?.insertDataWith(columnInfo: ["status" : statue.rawValue,"remoteUrl":"\(url.absoluteString)","nativeUrl":"\(nUrl.lastPathComponent)"])
        }else {
            flag = videoTable?.updateDataWith(updateItem: ["status":statue.rawValue,"nativeUrl":"\(nUrl.lastPathComponent)"], updateFilter: ["remoteUrl":"='\(url.absoluteString)'"], shouldOverride: false)
        }
        print("update flag=\(String(describing: flag))")

    }
    
    // MARK - delete video record
    func deleteVideRecordWithRemoteUrl(_ url:URL) {
        videoTable?.deleteDataWith(deleteFilter: ["remoteUrl":"='\(url.absoluteString)'"])
    }
    // 清空数据
    func clearAllRecord() -> Bool {
        return (videoTable?.deleteDataWith(deleteFilter: ["identifier":">'\(0)'"]))!
    }
}
