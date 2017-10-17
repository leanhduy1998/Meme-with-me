//
//  UserFiles.swift
//  Mememe
//
//  Created by Duy Le on 9/1/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import AWSS3
import MobileCoreServices
import AWSMobileHubHelper
import AVFoundation


import ObjectiveC

class UserFilesHelper {
    var manager = AWSUserFileManager.defaultUserFileManager()
    
    let UserFilesPublicDirectoryName = "public"
    let UserFilesPrivateDirectoryName = "private"
    let UserFilesProtectedDirectoryName = "protected"
    let UserFilesUploadsDirectoryName = "uploads"
    
    let S3BucketName = "mememe-userfiles-mobilehub-1008058883"
    
    var didLoadAllContents = false
    var marker: String! = nil
    
    func uploadData(directory: String, fileName: String, data: Data, progressView: UIProgressView, completeHandler: @escaping (_ url: URL)-> Void){
        let key: String = "\(directory)/\(fileName)"
        uploadWithData(data, forKey: key, progressView: progressView, completeHandler: completeHandler)
    }
    
    private func uploadWithData(_ data: Data, forKey key: String,progressView: UIProgressView,completeHandler: @escaping (_ url: URL)-> Void) {
        let localContent = manager.localContent(with: data, key: key)
        uploadLocalContent(localContent, progressView: progressView, completeHandler: completeHandler)
    }
    
    private func uploadLocalContent(_ localContent: AWSLocalContent,progressView: UIProgressView,completeHandler: @escaping (_ url: URL)-> Void) {
        localContent.uploadWithPin(onCompletion: false, progressBlock: {  (content: AWSLocalContent, progress: Progress) in
            progressView.progress = Float(progress.fractionCompleted)
        }) { (content, error) in
            if let error = error {
                print("Failed to upload an object. \(error)")
                //strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to upload an object.", cancelButtonTitle: "OK")
            } else {
                content?.getRemoteFileURL(completionHandler: { (url, err) in
                    if err == nil {
                        completeHandler(url!)
                    }
                    else {
                        print(err)
                    }
                })
                   // strongSelf.showSimpleAlertWithTitle("File upload", message: "File upload completed successfully for \(localContent.key).", cancelButtonTitle: "Okay")
            }
        }
    }
    
    private func loadMoreContents(directory: String, completeHandler: @escaping (_ contents: [AWSContent]) -> Void) {
        var contents = [AWSContent]()
        
        manager.listAvailableContents(withPrefix: directory, marker: marker) { (c, nextMarker, error) in
            
            if let error = error {
                print("Failed to load the list of contents. \(error)")
            }
            if let c = c, c.count > 0 {
                contents = c
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    self.didLoadAllContents = false
                } else {
                    self.didLoadAllContents = true
                }
                self.marker = nextMarker
                if self.didLoadAllContents == true {
                    completeHandler(contents)
                }
            }
        }
    }
    
    
    private func downloadContent(_ content: AWSContent, pinOnCompletion: Bool, completeHandler: @escaping (_ data: Data) -> Void) {
        
        content.download(with: .ifNotCached, pinOnCompletion: pinOnCompletion, progressBlock: {(content: AWSContent, progress: Progress) in
            print(progress)
        }) {(content: AWSContent?, data: Data?, error: Error?) in
            if let error = error {
                print("Failed to download a content from a server. \(error)")
            }
            completeHandler(data!)
        }
    }
    
    private func getOnlyFileNameNotDirectory(directory: String) -> String{
        for x in 1...(directory.characters.count-1) {
            let index = directory.index(directory.endIndex, offsetBy: -x)
            
            let tailString = directory.substring(from: index)
            if tailString.characters[tailString.startIndex] == "/" {
                let withoutSlashIndex = tailString.index(tailString.startIndex, offsetBy: 1)
                return tailString.substring(from: withoutSlashIndex)
            }
        }
        return ""
    }
    
    // image related
    
    
    func loadUserProfilePicture(userId: String, completeHandler: @escaping (_ image: Data) -> Void){
        loadMoreContents(directory: "public/compressedProfileImage/") { (contents) in
            for content in contents {
                if self.getOnlyFileNameNotDirectory(directory: content.key) == userId {
                    content.download(with: AWSContentDownloadType.ifNotCached, pinOnCompletion: false, progressBlock: { (content, progress) in
                    }, completionHandler: { (localContent, data, error) in
                        if error != nil {
                            print(error.debugDescription)
                        }
                        else {
                            completeHandler(data!)
                        }
                    })
                }
            }
        }
    }
 
    func getRandomMemeData(completeHandler: @escaping (_ imageData: Data, _ imageUrl: String) -> Void){
        loadMoreContents(directory: "public/memes/") { (contents) in
            let random = Int(arc4random_uniform(UInt32(contents.count)))
            contents[random].download(with: AWSContentDownloadType.ifNotCached, pinOnCompletion: false, progressBlock: { (content, progress) in
                
            }, completionHandler: { (content, imageData, error) in
                if error != nil {
                    print(error.debugDescription)
                }
                else {
                    completeHandler(imageData!, contents[random].key)
                }
            })
        }
    }
    
    func getMemeData(memeUrl: String, completeHandler: @escaping (_ imageData: Data) -> Void){
        loadMoreContents(directory: "public/memes/") { (contents) in
            
            for c in contents {
                if c.key == memeUrl {
                    c.download(with: AWSContentDownloadType.ifNotCached, pinOnCompletion: false, progressBlock: { (content, progress) in
                        
                    }, completionHandler: { (content, imageData, error) in
                        if error != nil {
                            print(error.debugDescription)
                        }
                        else {
                            completeHandler(imageData!)
                        }
                    })
                    break
                }
            }
        }
    }
    

}
