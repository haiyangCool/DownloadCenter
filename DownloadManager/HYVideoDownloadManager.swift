//
//  HYVideoDownloadManager.swift
//  DownLoadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//


import UIKit
import Alamofire
class HYVideoDownloadManager: NSObject{

    /// session manager
    lazy var sessionManager:SessionManager = {
        sessionsManager()
    }()
    /// download strategy
    var downStrategy:KHYVideoDownloadStrategy? = .HYVideoDownloadStrategyOnlyForeground
    /// max concurrnet downloading num
    var maxConcurrentDownloadNum:Int = 3
    /// timeoutInterval For Request
    var timeoutIntervalForRequest:TimeInterval = 10.0
    /// timeoutInterval For Resource
    var timeoutIntervalForResource:TimeInterval = 10.0

    
    /// download video data center
    lazy var videoDataCenter:HYVideoDownloadDataCenter = {
        videodataCenter()
    }()
    /// download task pool
    var downloadPool:[URL:DownloadRequest] = [:]
    
    /// shared
    static let shared = HYVideoDownloadManager()
    override init() {
        
    }
}

extension HYVideoDownloadManager {
    
    //MARK:- download video with url
    func startDownloadVideoTask(_ withUrl:URL?) {
        
        if withUrl == nil { return }
        let url = withUrl!
        var videoStatus = self.videoDataCenter.videoStatusWithRemoteUrl(url)
        
        if videoStatus == .hyVideoStatusDownloading || videoStatus == .hyVideoStatusWaitingForDownload {
            /// if task == nil ,set status faild, then the .hyVideoStatusDownfaild will reload this video
            let downloadTask = downloadPool[url]
            if downloadTask == nil {
                videoStatus = .hyVideoStatusDownloadfaild
                /// record this status
                videoDataCenter.updateVideoStatus(.hyVideoStatusDownloadfaild, remoteUrl: url)
            }
        }
        
        if videoStatus == .hyVideoStatusNative {
            /// if finish download then post notification
            NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoDidFinishDownloadNotification),
                                            object: nil,
                                            userInfo: [KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification :1.0,
                                            KHYDownloadManagerUserinfoKeyNativeUrlNotification:url,
                                            KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url])
        }
        
        if videoStatus == .hyVideoStatusDownloadFinished {
            let nativeUrl = self.videoDataCenter.nativeUrlWithRemoteUrl(url)
            if nativeUrl != nil {
                NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoDidFinishDownloadNotification),
                                                object: nil,
                                                userInfo: [KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification:1.0,
                                                KHYDownloadManagerUserinfoKeyRemoteUrlListNotification:url,
                                                KHYDownloadManagerUserinfoKeyNativeUrlNotification:nativeUrl!])
            }
            
        }
        
        
        /// resume download video with url
        if videoStatus == .hyVideoStatusDownloadfaild {
            resumeDownloadWithUrl(url)
        }
        if videoStatus == .hyVideoStatusNotFound {
            resumeDownloadWithUrl(url)
        }
        if videoStatus == .hyVideoStatusPaused {
            resumeDownloadWithUrl(url)
        }
        
    }

    /// start all download Task
    func startAllCouldDownloadTask() {
        var allRecordList:[URL] = []
   
        if let waitingRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusWaitingForDownload)  {
            allRecordList.append(contentsOf: waitingRecordList)
        }
        if let pausedRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusPaused) {
            allRecordList.append(contentsOf: pausedRecordList)
        }
        if let faildRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusDownloadfaild) {
            allRecordList.append(contentsOf: faildRecordList)
        }
        
        if allRecordList.isEmpty { return }
        for url in allRecordList {
            let downloadTask = downloadPool[url]
            if downloadTask == nil {
                resumeDownloadWithUrl(url)
            }
            
        }

    }
    
    /// delete video by url
    func deleteRecordWithRemoteUrl(_ url:URL?) {
        if url == nil { return }
        let downloadTask = downloadPool[url!]
        if downloadTask != nil {
            downloadTask?.cancel()
            downloadPool.removeValue(forKey: url!)
        }
        
        videoDataCenter.deleteVideRecordWithRemoteUrl(url!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KHYDownloadManagerDidDeleteDownloadVideoNotification),
                                        object: nil,
                                        userInfo: [
                                            KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url!
            ])
        
    }
    /// delete all video and download Task
    func deleteAllRecordAndVideo(_ complication:@escaping (Bool)->Void) {
        
        /// delete all download pool task
        for (url,downloadTask) in downloadPool {
            downloadTask.cancel()
        }
        downloadPool.removeAll()
        /// delete all finished record
        DispatchQueue.global().async {
            let finishedRecord = self.videoDataCenter.recordListWithStatus(.hyVideoStatusDownloadFinished)
            if finishedRecord != nil && (finishedRecord?.count)! > 0 {
                for record in finishedRecord! {
                    let nativeUrl:String = record["remoteUrl"] as! String
                    let filePath = URL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]+nativeUrl)
                    try? FileManager.default.removeItem(at: filePath)
                }
            }
        }
        /// clear download record list
        let clearAll = videoDataCenter.clearAllRecord()
        complication(clearAll)
    }
    /// pause download Task by url
    func pauseDownloadTaskWithRemoteUrl(_ url:URL,_ complication:@escaping ()->Void
        ) {
        videoDataCenter.updateVideoStatus(.hyVideoStatusPaused, remoteUrl: url)
        let downloadTask = downloadPool[url]
        
        if downloadTask != nil {
            downloadTask?.cancel()
            var resumeData:Data?
            downloadTask?.responseData(completionHandler: { [weak self](response) in
                
                resumeData = response.resumeData
                if resumeData != nil {
                    let nativeUrl = self?.videoDataCenter.nativeUrlWithRemoteUrl(url)
                    let resumeUrl = nativeUrl?.appendingPathExtension("resume")
                    try? resumeData?.write(to: resumeUrl!, options: Data.WritingOptions.atomic)
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoDidDownloadPausedNotification),
                                                    object: nil,
                                                    userInfo: [
                                                        KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url,
                                                        KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification:Float((downloadTask?.progress.completedUnitCount)!)/Float((downloadTask?.progress.totalUnitCount)!)
                        ])
                }
                 complication()
            })

        }
        downloadPool.removeValue(forKey: url)
        
    }
    /// pause all download task
    func pauseAllDownloadTask() {
      
        var recordList:[URL] = []
        if let failDownloaddRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusDownloadfaild) {
            recordList.append(contentsOf: failDownloaddRecordList)
        }
        if let waitDownloadRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusWaitingForDownload) {
            recordList.append(contentsOf: waitDownloadRecordList)
        }
        if let downloadRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusDownloading) {
            recordList.append(contentsOf: downloadRecordList)
        }
        if let pausedRecordList = videoDataCenter.recordRemoteUrlListWithStatus(.hyVideoStatusPaused) {
            recordList.append(contentsOf: pausedRecordList)
        }
        if recordList.isEmpty { return }
        for (index,url) in recordList.enumerated() {
            videoDataCenter.updateVideoStatus(.hyVideoStatusPaused, remoteUrl: url)
        }
        for (url,downloadTask) in downloadPool {
            downloadTask.cancel()
            downloadTask.responseData { [weak self](response) in
                let resumeData = response.resumeData
                if resumeData != nil {
                    let nativeUrl = self?.videoDataCenter.nativeUrlWithRemoteUrl(url)
                    let resumeUrl = nativeUrl?.appendingPathExtension("resume")
                    try? resumeData?.write(to: resumeUrl!, options: Data.WritingOptions.atomic)
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoDidDownloadPausedNotification),
                                                    object: nil,
                                                    userInfo: [
                                                        KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url,
                                                        KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification:Float((downloadTask.progress.completedUnitCount))/Float((downloadTask.progress.totalUnitCount))
                        ])
                }
                
            }
            
        }
        downloadPool.removeAll()
        
    }
}

// MARK:- Private method
extension HYVideoDownloadManager {
    /// continue download video
    func resumeDownloadWithUrl(_ url:URL) {
        /// download video
        if downStrategy == .HYVideoDownloadStrategyNoDownload {
            return
        }
        let nativeUrl = videoDataCenter.nativeUrlWithRemoteUrl(url)
        if nativeUrl == nil {
            downloadVideoWithUrl(url)
            return
        }
        let resumeUrl = nativeUrl!.appendingPathExtension("resume")
        let fileData = try? Data.init(contentsOf: resumeUrl)
        if fileData == nil {
            downloadVideoWithUrl(url)
            return
        }else {
            try? FileManager.default.removeItem(at: resumeUrl)
        }
        /// continue download
        let dataTask = sessionManager.download(resumingWith: fileData!) { (url, rulResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (nativeUrl!,.removePreviousFile)
            }.downloadProgress { [weak self] (progress) in
                self?.handleDownloadProgress(progress, remoteUrl: url, nativeUrl: nativeUrl)
            }.response { [weak self] (downlooadResponse) in
                self?.handleDownloadComplection(url, downloadResponse: downlooadResponse, filePath: nativeUrl, downloadError: downlooadResponse.error)
        }
        dataTask.resume()
        downloadPool[url] = dataTask
        videoDataCenter.updateVideoStatus(.hyVideoStatusWaitingForDownload, remoteUrl: url)
        NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoWillDownloadNotification),
                                        object: nil,
                                        userInfo: [
                
                                            KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url,
                
                                            KHYDownloadManagerUserinfoKeyNativeUrlNotification:nativeUrl!
            ])
        
     
    }
    
    /// download
    func downloadVideoWithUrl(_ url:URL) {
        
        var nativeUrl = videoDataCenter.nativeUrlWithRemoteUrl(url)
        if nativeUrl == nil {
            let fileName = "/" + NSUUID.init().uuidString + ".mp4"
            nativeUrl = URL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]+fileName)
        }
        videoDataCenter.updateVideoStatue(.hyVideoStatusWaitingForDownload, remoteUrl: url, nativeUrl: nativeUrl!)
        
        
        let dataTask = sessionManager.download(url) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (nativeUrl!,.removePreviousFile)
            }.downloadProgress { [weak self] (progress) in
                self?.handleDownloadProgress(progress, remoteUrl: url, nativeUrl: nativeUrl)
            }.response { [weak self](response) in
                self?.handleDownloadComplection(url, downloadResponse: response, filePath: nativeUrl, downloadError: response.error)
        }
        dataTask.resume()
        downloadPool[url] = dataTask
        videoDataCenter.updateVideoStatus(.hyVideoStatusWaitingForDownload, remoteUrl: url)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerVideoWillDownloadNotification),
                                        object: nil,
                                        userInfo: [
                                            KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url
            ])
    }
    
    /// download complection
    func handleDownloadComplection(_ url:URL,downloadResponse response:DefaultDownloadResponse, filePath path:URL?, downloadError error:Error? )  {
        var notification:String?
        downloadPool.removeValue(forKey: url)
        
        if error != nil || path == nil {
            notification = KHYDownloadManagerVideoDownloadFaildNotification
            videoDataCenter.updateVideoStatus(.hyVideoStatusDownloadfaild, remoteUrl: url)
            let resumeData = response.resumeData
            if resumeData != nil {
                let nativeUrl = videoDataCenter.nativeUrlWithRemoteUrl(url)
                let resumeUrl = nativeUrl?.appendingPathExtension("resume")
                try? resumeData?.write(to: resumeUrl!, options: Data.WritingOptions.atomic)
            }
        }else {
            notification = KHYDownloadManagerVideoDidFinishDownloadNotification
            videoDataCenter.updateVideoStatus(.hyVideoStatusDownloadFinished, remoteUrl: url)
        }
        
        let userNotiInfo = [KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url,KHYDownloadManagerUserinfoKeyNativeUrlNotification:path!]
        
        NotificationCenter.default.post(name: NSNotification.Name.init(notification!), object: nil, userInfo: userNotiInfo)
        
        
    }
    /// progress handle
    func handleDownloadProgress(_ downloadProgress:Progress, remoteUrl url:URL, nativeUrl nUrl:URL?) {
        
        let progress = Float(downloadProgress.completedUnitCount)/Float(downloadProgress.totalUnitCount)
        if progress < 1.0 {
            let userNotiInfo = [
                            KHYDownloadManagerUserinfoKeyNativeUrlNotification:nUrl!,
                            KHYDownloadManagerUserinfoKeyRemoteUrlNotification:url,
                            KHYDownloadManagerVideoDownloadProgressNotification:progress
                ] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name.init(KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification),
                                            object: nil,
                                            userInfo: userNotiInfo)
            videoDataCenter.updateVideoStatus(.hyVideoStatusDownloading, remoteUrl: url)
        }
        
    }
    /// sessionManager
    func sessionsManager() -> SessionManager {
       
        if downStrategy == .HYVideoDownloadStrategyOnlyForeground {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
            configuration.timeoutIntervalForResource = timeoutIntervalForResource
            sessionManager = SessionManager(configuration: configuration)
        }
        if downStrategy == .HYVideoDownloadStrategyForegroundAndBackground {
            let identifier = "HYVideodownload"+NSUUID.init().uuidString
            let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
//            configuration.sessionSendsLaunchEvents = true
//            configuration.isDiscretionary = true
            configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
            configuration.timeoutIntervalForResource = timeoutIntervalForResource
            sessionManager = SessionManager(configuration: configuration)
        }
        sessionManager.session.delegateQueue.maxConcurrentOperationCount = 3
        return sessionManager
    }
    /// data center
    func videodataCenter() -> HYVideoDownloadDataCenter {
    
        videoDataCenter = HYVideoDownloadDataCenter.init()

        return videoDataCenter
    }
}
