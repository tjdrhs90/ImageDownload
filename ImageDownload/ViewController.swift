//
//  ViewController.swift
//  ImageDownload
//
//  Created by seonggon on 2023/02/28.
//

import UIKit

final class ViewController: UIViewController {
    
    ///이미지뷰 배열
    @IBOutlet private var imageViews: [UIImageView]!
    ///프로그래스뷰 배열
    @IBOutlet private var progressViews: [UIProgressView]!
    ///이미지 URL 배열
    private var imageUrls = ["https://sample-videos.com/img/Sample-jpg-image-200kb.jpg",
                             "https://sample-videos.com/img/Sample-png-image-200kb.png",
                             "https://sample-videos.com/img/Sample-jpg-image-1mb.jpg",
                             "https://sample-videos.com/img/Sample-png-image-3mb.png",
                             "https://sample-videos.com/gif/2.gif"]
    
    ///기본 이미지
    private let basicImage = UIImage(systemName: "photo")
    
    ///다운로드 태스크 딕셔너리
    private var activeDownloads: [Int : URLSessionDownloadTask] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /// 다운로드
    /// - Parameter tag: 배열 인덱스
    private func download(_ tag: Int) {
        guard let url = URL(string: imageUrls[tag]) else { return }
        
        let config = URLSessionConfiguration.default
        
        config.sharedContainerIdentifier = String(tag)
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        progressViews[tag].progress = 0
        
        imageViews[tag].image = basicImage
        
        if let activeDownload = activeDownloads[tag] {
            activeDownload.cancel()
            activeDownloads[tag] = nil
        }
        
        let task = session.downloadTask(with: url)
        activeDownloads[tag] = task
        task.resume()
    }
    
    //MARK: - @IBAction
    //읽기 버튼 터치
    @IBAction func loadButtonTap(_ sender: UIButton) {
        download(sender.tag)
    }
    
    //전체 이미지 읽기 버튼 터치
    @IBAction func loadAllImagesButtonTap(_ sender: UIButton) {
        imageViews.forEach { download($0.tag) }
    }
}

//MARK: - URLSessionDownloadDelegate
extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let tag = session.tag else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.progressViews[tag].progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let tag = session.tag,
              let data = try? Data(contentsOf: location),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.imageViews[tag].image = image
        }
    }
}

//MARK: - extension URLSession
extension URLSession {
    ///세션 태그 변환
    var tag: Int? {
        guard let identifier = configuration.sharedContainerIdentifier else { return nil }
        return Int(identifier)
    }
}
