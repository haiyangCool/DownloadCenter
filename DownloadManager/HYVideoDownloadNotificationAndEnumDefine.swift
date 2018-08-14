//
//  HYVideoDownloadNotificationAndStructDefine.swift
//  DownloadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
import UIKit

extension Notification.Name {
    ///  will post "willDownload"  when a task before download
    public static let willDownload = Notification.Name(rawValue: "self.hyDownloadManager.Notification.name.willDownload")
    ///  will post "downloadProgress" when a task is downloading
    public static let downloadProgress = Notification.Name(rawValue: "self.hyDownloadManager.Notification.name.downloadProgress")
    ///  will post "finishedDownload" when a task is download success
    public static let finishedDownload = Notification.Name(rawValue: "self.hyDownloadManager.Notification.name.finishedDownload")
    ///  will post "downloadFaild" when a task is download fiald
    public static let downloadFaild = Notification.Name(rawValue:
        "self.hyDownloadManager.Notification.name.downloadFaild")
    ///  will post "pausedDownload" when a task is paused by user tap
    public static let pausedDownload = Notification.Name(rawValue: "self.hyDownloadManager.Notification.name.pausedDownload")
    /// will post "deleteDownload" when user delete a download task
    public static let deleteDownload = Notification.Name(rawValue: "self.hyDownloadManager.Notification.name.deleteDownload")
    /// post "remoreUrl" the net service address of download task
    public static let remoreUrl = Notification.Name(rawValue: "self.userInfoKey.Notification.name.remoteUrl")
    /// post "remoreUrlList" all net service address of download (faild,paused,willDownload)
    public static let remoreUrlList = Notification.Name(rawValue: "self.userInfoKey.Notification.name.remoteUrlList")
    /// post "nativeUrl" the native path of download success
    public static let nativeUrl = Notification.Name(rawValue: "self.userInfoKey.Notification.name.nativeUrl")
    /// post "userDownloadProgress" the current progress when a task be paused or faild have a accident
    public static let userDownloadProgress = Notification.Name(rawValue: "self.userInfoKey.Notification.name.userDownloadProgress")
}

/// download strategy
enum KHYVideoDownloadStrategy:String {
    case HYVideoDownloadStrategyNoDownload
    case HYVideoDownloadStrategyOnlyForeground
    case HYVideoDownloadStrategyForegroundAndBackground
}
import UIKit

class HYVideoDownloadNotificationAndEnumDefine: NSObject {

}
