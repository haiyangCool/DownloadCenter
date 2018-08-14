//
//  ViewController.swift
//  DownloadCenter
//
//  Created by hyw on 2018/7/17.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
var videoUrl:String = "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"
var videoUrl2:String = "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"

class ViewController: UIViewController {

    /// 只做测试
    let videoList = [videoUrl]
    var videoDownloadProgress = Array(repeating: 0.0, count: 1)
    var videoListTab:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        videoListTab = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.size.height), style: .plain)
        videoListTab.backgroundColor = UIColor.lightGray
        videoListTab.estimatedRowHeight = 0
        videoListTab.estimatedSectionFooterHeight = 0
        videoListTab.estimatedSectionHeaderHeight = 0
        videoListTab.delegate = self
        videoListTab.dataSource = self
        self.view.addSubview(videoListTab)
        
        addDownloadNotification()
        // Do any additional setup after loading the view, typically from a nib.
    }
   
    
    @objc func pause() {
        
        let downloadManager = HYVideoDownloadManager.shared
//        downloadManager.pauseDownloadTaskWithRemoteUrl(URL.init(string: videoUrl)!) {
//            print("暂停执行完")
//        }

        downloadManager.pauseAllDownloadTask()
        
    
    }
    @objc func addDownloadNotification() {
        
        //指定下载路径
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(noti:)), name: .downloadProgress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadComplection(noti:)), name: .finishedDownload, object: nil)
        

    }
    
    @objc func downloadProgress(noti:Notification) {
        let notiInfo = noti.userInfo
        videoListTab.backgroundColor = UIColor.yellow
    
        let progress:Float = notiInfo![Notification.Name.downloadProgress.rawValue] as! Float
        videoDownloadProgress[0] = Double(progress)
        videoListTab.reloadData()
        
        
    }
    
    @objc func downloadComplection(noti:Notification)  {
        let notiInfo = noti.userInfo
        let url:URL = notiInfo![Notification.Name.nativeUrl.rawValue] as! URL
        print("下载完  ********* 、\(url)")
        videoDownloadProgress[0] = 1.0
        videoListTab.reloadData()
        
    }
    
    @objc func startPlay(_ btn:UIButton) {
        let urlStr = videoList[btn.tag-1000]
        let url = URL.init(string: urlStr)
        if url == nil {
            return
        }
        let downloadManager = HYVideoDownloadManager.shared

        let path:URL = downloadManager.videoDataCenter.nativeUrlWithRemoteUrl(url!)!
        play(url: path)
    }
    func play(url:URL) {
        let playerLayer = AVPlayerLayer.init()
        playerLayer.frame = CGRect.init(x: 0, y: 400, width: self.view.bounds.size.width, height: self.view.bounds.size.width*9.0/16.0)
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        self.view.layer.addSublayer(playerLayer)
        
        let avasset = AVAsset.init(url: url)
        let duration = avasset.duration
        
        let playerItem = AVPlayerItem.init(asset: avasset)
        let player = AVPlayer.init(playerItem: playerItem)
        playerLayer.player = player
        player.play()
        
    }
    @objc func startDownload(_ btn:UIButton) {
        
        let urlStr = videoList[btn.tag-1000]
        let url = URL.init(string: urlStr)
        if url == nil {
            return
        }
        videoListTab.backgroundColor = UIColor.white
        let downloadManager = HYVideoDownloadManager.shared
        downloadManager.startDownloadVideoTask(url)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "videoDownloadCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "videoDownloadCell")
        }
        for sub in (cell?.contentView.subviews)! {
            sub.removeFromSuperview()
        }
        let progressLabel = UILabel()
        progressLabel.frame = CGRect.init(x: 10, y: 10, width: 120, height: 20)
        progressLabel.backgroundColor = UIColor.clear
        progressLabel.textColor = UIColor.orange
        cell?.contentView.addSubview(progressLabel)
        
        
        
        let downloadBtn = UIButton()
        downloadBtn.frame = CGRect.init(x: 300, y: 10, width: 40, height: 40)
        downloadBtn.tag = indexPath.row + 1000
        downloadBtn.backgroundColor = UIColor.clear
        downloadBtn.setTitle("下载", for: .normal)
        downloadBtn.setTitleColor(UIColor.orange, for: .normal)
        downloadBtn.setTitleColor(UIColor.gray, for: .highlighted)
        downloadBtn.addTarget(self, action: #selector(startDownload(_:)), for: .touchUpInside)
        cell?.contentView.addSubview(downloadBtn)
        
        
        let playBtn = UIButton()
        playBtn.frame = CGRect.init(x: 300, y: 10, width: 40, height: 40)
        playBtn.tag = indexPath.row + 1000
        playBtn.backgroundColor = UIColor.clear
        playBtn.setTitle("Play", for: .normal)
        playBtn.setTitleColor(UIColor.orange, for: .normal)
        playBtn.setTitleColor(UIColor.gray, for: .highlighted)
        playBtn.addTarget(self, action: #selector(startPlay(_:)), for: .touchUpInside)
        playBtn.isHidden = true
        cell?.contentView.addSubview(playBtn)
        
        let progress = videoDownloadProgress[indexPath.row]
        progressLabel.text = "进度\(progress)"
        
        if progress >= 1.0 {
            downloadBtn.isHidden = true
            playBtn.isHidden = false
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

