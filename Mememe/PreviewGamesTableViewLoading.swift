//
//  PreviewGamesTableViewLoading.swift
//  Mememe
//
//  Created by Duy Le on 11/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension PreviousGamesViewController{
    func loadTwoImagesCell(cell: PreviewGamesTwoImageCell, game:Game, indexPath: IndexPath) -> PreviewGamesTwoImageCell {
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        
        let players = game.players?.allObjects as? [Player]
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        //let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        
        var playersImages = playerImagesInGameDic[game.gameId!]!
        var ivOrder = Array(playersImages.keys)
        
        var imageLoadedCount = 0
        
        if playersImages[ivOrder[0]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[0]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[0], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[0]] = compressedImage
                        cell.firstIV.image = compressedImage
                        self.playerImageDownload[ivOrder[0]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 2 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                cell.firstIV.image = playerImageDownload[ivOrder[0]]
                playersImages[ivOrder[0]] = playerImageDownload[ivOrder[0]]
                imageLoadedCount = imageLoadedCount + 1
            }
            
        }
        else {
            cell.firstIV.image = playersImages[ivOrder[0]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[1]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[1]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[1], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[1]] = compressedImage
                        cell.secondIV.image = compressedImage
                        self.playerImageDownload[ivOrder[1]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        if imageLoadedCount == 2 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                imageLoadedCount = imageLoadedCount + 1
                cell.secondIV.image = self.playerImageDownload[ivOrder[1]]
            }
        }
        else {
            cell.secondIV.image = playersImages[ivOrder[1]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
 //       playerImagesInGameDic[game.gameId!] = playersImages
        
        if imageLoadedCount == 2 {
            self.sections[indexPath.section].finishLoading = true
            playerImagesInGameDic[game.gameId!] = playersImages
        }
        return cell
    }
    
    func loadThreeImagesCell(cell: PreviewGamesThreeImageCell, game:Game, indexPath: IndexPath) -> PreviewGamesThreeImageCell {
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        
        let players = game.players?.allObjects as? [Player]
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        //let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        
        var imageLoadedCount = 0
        
        var playersImages = playerImagesInGameDic[game.gameId!]!
        var ivOrder = Array(playersImages.keys)
        
        if playersImages[ivOrder[0]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[0]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[0], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[0]] = compressedImage
                        cell.firstIV.image = compressedImage
                        self.playerImageDownload[ivOrder[0]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 3 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                cell.firstIV.image = playerImageDownload[ivOrder[0]]
                playersImages[ivOrder[0]] = playerImageDownload[ivOrder[0]]
                imageLoadedCount = imageLoadedCount + 1
            }
            
        }
        else {
            cell.firstIV.image = playersImages[ivOrder[0]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[1]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[1]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[1], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[1]] = compressedImage
                        cell.secondIV.image = compressedImage
                        self.playerImageDownload[ivOrder[1]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        if imageLoadedCount == 3 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                imageLoadedCount = imageLoadedCount + 1
                cell.secondIV.image = self.playerImageDownload[ivOrder[1]]
                playersImages[ivOrder[1]] = self.playerImageDownload[ivOrder[1]]
            }
        }
        else {
            cell.secondIV.image = playersImages[ivOrder[1]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[2]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[2]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[2], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[2]] = compressedImage
                        cell.thirdIV.image = compressedImage
                        self.playerImageDownload[ivOrder[2]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 3 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                cell.thirdIV.image = self.playerImageDownload[ivOrder[2]]
                playersImages[ivOrder[2]] = playerImageDownload[ivOrder[2]]
                imageLoadedCount = imageLoadedCount + 1
            }
        }
        else {
            cell.thirdIV.image = playersImages[ivOrder[2]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
  //      playerImagesInGameDic[game.gameId!] = playersImages
        if imageLoadedCount == 3 {
            self.sections[indexPath.section].finishLoading = true
            playerImagesInGameDic[game.gameId!] = playersImages
        }
        return cell
    }
    
    func loadFourImagesCell(cell: PreviewGamesFourImageCell, game:Game, indexPath: IndexPath) -> PreviewGamesFourImageCell {
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        
        let players = game.players?.allObjects as? [Player]
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        //let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        cell.fourthIV = CircleImageCutter.roundImageView(imageview: cell.fourthIV, radius: 5)
        
        var playersImages = playerImagesInGameDic[game.gameId!]!
        var ivOrder = Array(playersImages.keys)
        
        var imageLoadedCount = 0
        
        if playersImages[ivOrder[0]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[0]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[0], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[0]] = compressedImage
                        cell.firstIV.image = compressedImage
                        self.playerImageDownload[ivOrder[0]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 4 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                cell.firstIV.image = playerImageDownload[ivOrder[0]]
                playersImages[ivOrder[0]] = playerImageDownload[ivOrder[0]]
                imageLoadedCount = imageLoadedCount + 1
            }
            
        }
        else {
            cell.firstIV.image = playersImages[ivOrder[0]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[1]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[1]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[1], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[1]] = compressedImage
                        cell.secondIV.image = compressedImage
                        self.playerImageDownload[ivOrder[1]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        if imageLoadedCount == 4 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                playersImages[ivOrder[1]] = playerImageDownload[ivOrder[1]]
                imageLoadedCount = imageLoadedCount + 1
                cell.secondIV.image = self.playerImageDownload[ivOrder[1]]
            }
        }
        else {
            cell.secondIV.image = playersImages[ivOrder[1]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[2]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[2]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[2], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[1]] = compressedImage
                        cell.thirdIV.image = compressedImage
                        self.playerImageDownload[ivOrder[2]] = compressedImage
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 4 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                playersImages[ivOrder[2]] = playerImageDownload[ivOrder[2]]
                cell.thirdIV.image = self.playerImageDownload[ivOrder[2]]
                imageLoadedCount = imageLoadedCount + 1
            }
        }
        else {
            cell.thirdIV.image = playersImages[ivOrder[2]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if playersImages[ivOrder[3]] == #imageLiteral(resourceName: "ichooseyou") {
            if playerImageDownload[ivOrder[3]] == nil {
                helper.loadUserProfilePicture(userId: ivOrder[3], completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                        playersImages[ivOrder[1]] = compressedImage
                        cell.fourthIV.image = compressedImage
                        self.playerImageDownload[ivOrder[3]] = compressedImage
                        
                        imageLoadedCount = imageLoadedCount + 1
                        
                        if imageLoadedCount == 4 {
                            self.sections[indexPath.section].finishLoading = true
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                        }
                    }
                })
            }
            else{
                playersImages[ivOrder[3]] = playerImageDownload[ivOrder[3]]
                cell.fourthIV.image = self.playerImageDownload[ivOrder[3]]
                imageLoadedCount = imageLoadedCount + 1
            }
        }
        else {
            cell.fourthIV.image = playersImages[ivOrder[3]]
            imageLoadedCount = imageLoadedCount + 1
        }
        
        if imageLoadedCount == 4 {
            self.sections[indexPath.section].finishLoading = true
            playerImagesInGameDic[game.gameId!] = playersImages
        }
        
        return cell
    }
}
