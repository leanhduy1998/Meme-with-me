//
//  FileManager.swift
//  Mememe
//
//  Created by Duy Le on 10/20/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class FileManagerHelper{
    private static var fileManager: FileManager!
    private static var mememeURL: URL!
    
    private static func setup(){
        fileManager = FileManager.default
        mememeURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        mememeURL = mememeURL.appendingPathComponent("Mememe")
        
        createDirectory(directory: mememeURL.path)
    }
    private static func createDirectory(directory: String){
        if !fileManager.fileExists(atPath: directory) {
            do{
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: false, attributes: nil)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
    static func insertImageIntoMemory(imageName: String, directory: [String], image: UIImage) -> String{
        if(fileManager == nil){
            setup()
        }
        
        var directoryURL = mememeURL!
        var filePath: URL!
        var fileDirectoryString = ""
        
        if(directory.count != 0){
            for d in directory{
                directoryURL = directoryURL.appendingPathComponent(d)
                createDirectory(directory: directoryURL.path)
                fileDirectoryString = "\(fileDirectoryString)/\(d)"
            }
            fileDirectoryString = "\(fileDirectoryString)/\(imageName).png"
        }
        else{
            fileDirectoryString = "\(imageName).png"
        }
        
        filePath = directoryURL.appendingPathComponent("\(imageName).png")
        do{
            let files = try fileManager.contentsOfDirectory(atPath: directoryURL.path)
            for file in files{
                if "\(directoryURL.path)/\(file)" == filePath.path{
                    try fileManager.removeItem(atPath: filePath.path)
                }
            }
        }
        catch{
            print(error.localizedDescription)
        }
        do{
           // let compressedImage = UIImageJPEGRepresentation(image, 1)
            
            if let pngImageData = UIImageJPEGRepresentation(image, 0.0){
                try pngImageData.write(to: filePath, options: .atomic)
            }
        }
        catch{
            print(error.localizedDescription)
        }
        
        return fileDirectoryString
    }
    static func getImageFromMemory(imagePath: String) -> UIImage{
        if(fileManager == nil){
            setup()
        }
        
        let path = mememeURL.appendingPathComponent(imagePath)
        /*
        do{
            let files = try fileManager.contentsOfDirectory(atPath: mememeURL.path)
            for file in files{
                print("\(mememeURL.path)/\(file)")
                print(path.path)
                if "\(mememeURL.path)/\(file)" == path.path{
                    if let contentsOfFilePath = UIImage(contentsOfFile: path.path){
                        return contentsOfFilePath
                    }
                }
            }
        }
        catch{
            print(error.localizedDescription)
        }*/
        
        if fileManager.fileExists(atPath: path.path){
            if let contentsOfFilePath = UIImage(contentsOfFile: path.path){
                return contentsOfFilePath
            }
        }
        return UIImage()
    }
    static func getPlayerIdForStorage(playerId: String)->String{
        // original playerId have us-east-1/ before it, making it hard to store the images
        var playerIdForStorage = playerId
        
        let index = playerIdForStorage.index(playerIdForStorage.startIndex, offsetBy: 10)
        playerIdForStorage = playerIdForStorage.substring(from: index)
        return playerIdForStorage
    }
}
