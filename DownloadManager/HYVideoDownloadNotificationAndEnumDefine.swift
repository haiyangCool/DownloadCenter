//
//  HYVideoDownloadNotificationAndStructDefine.swift
//  DownloadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//
/// will download video
let KHYDownloadManagerVideoWillDownloadNotification = "KHYDownloadManagerVideoWillDownloadNotification"
/// video downloading progress
let KHYDownloadManagerVideoDownloadProgressNotification = "KHYDownloadManagerVideoDownloadProgressNotification"
/// video download finished
let KHYDownloadManagerVideoDidFinishDownloadNotification = "KHYDownloadManagerVideoDidFinishDownloadNotification"
/// video download failed
let KHYDownloadManagerVideoDownloadFaildNotification = "KHYDownloadManagerVideoDidDownloadFaildNotification"
/// video download pause
let KHYDownloadManagerVideoDidDownloadPausedNotification = "KHYDownloadManagerVideoDidDownloadPausedNotification"
/// delete download video
let KHYDownloadManagerDidDeleteDownloadVideoNotification = "KHYDownloadManagerDidDeleteDownloadVideoNotification"
/// User info notification by user use
/// remote url
let KHYDownloadManagerUserinfoKeyRemoteUrlNotification = "KHYDownloadManagerUserinfoKeyRemoteUrlNotification"
/// remoteURL list
let KHYDownloadManagerUserinfoKeyRemoteUrlListNotification = "KHYDownloadManagerUserinfoKeyRemoteUrlListNotification"
/// native url
let KHYDownloadManagerUserinfoKeyNativeUrlNotification = "KHYDownloadManagerUserinfoKeyNativeUrlNotification"
/// video download progress
let KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification = "KHYDownloadManagerUserinfoKeyVideoDownloadProgressNotification"

/// download strategy
enum KHYVideoDownloadStrategy:String {
    case HYVideoDownloadStrategyNoDownload
    case HYVideoDownloadStrategyOnlyForeground
    case HYVideoDownloadStrategyForegroundAndBackground
}
import UIKit

class HYVideoDownloadNotificationAndEnumDefine: NSObject {

}
