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
    private static var documentsURL: URL!
    private static var documentsPath: String!
    
    private static func setup(){
        fileManager = FileManager.default
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsURL = documentsURL.appendingPathComponent("Mememe")
        documentsPath = documentsURL.path
        
        if !fileManager.fileExists(atPath: documentsPath) {
            do{
                try fileManager.createDirectory(atPath: documentsPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
    static func insertImageIntoMemory(imageName: String, directory: String, image: UIImage) -> String{
        if(fileManager == nil){
            setup()
        }
        
        var filePath = documentsURL!
        
        if(directory != ""){
            filePath = documentsURL.appendingPathComponent(directory)
        }
        filePath = documentsURL.appendingPathComponent("\(imageName).png")
        do{
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            for file in files{
                if "\(documentsPath)/\(file)" == filePath.path{
                    try fileManager.removeItem(atPath: filePath.path)
                }
            }
        }
        catch{
            print(error.localizedDescription)
        }
        do{
            let compressedImage = UIImage(data: image.jpeg(UIImage.JPEGQuality.lowest)!)
            if let pngImageData = UIImagePNGRepresentation(compressedImage!){
                try pngImageData.write(to: filePath, options: .atomic)
            }
        }
        catch{
            print(error.localizedDescription)
        }
        
        return imageName
    }
    static func getImageFromMemory(imagePath: String) -> UIImage{
        if(fileManager == nil){
            setup()
        }
        
        if fileManager.fileExists(atPath: imagePath){
            if let contentsOfFilePath = UIImage(contentsOfFile: imagePath){
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
