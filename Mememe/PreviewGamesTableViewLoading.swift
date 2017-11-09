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
    func loadTwoImagesCell(cell: PreviewGamesTwoImageCell, game:Any, indexPath: IndexPath) -> PreviewGamesTwoImageCell {
        
        let cell = CellAnimator.add(cell: cell)
        
        if selectedAll {
            cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
        }
        else{
            if selectedIndexPath[indexPath] == true {
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else{
                cell.accessoryType = cell.isSelected ? .checkmark : .none
            }
        }
        
        cell.selectionStyle = .none
        cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 5)
        
        if let game = game as? Game {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.players?.allObjects as? [Player]
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
            
            if playerImagesInGameDic[game.gameId!]![0].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId] == nil {
                    helper.loadUserProfilePicture(userId: playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.firstIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
 
                            DispatchQueue.main.async {
                                cell.firstIV.image = image
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] = image
                            }
                        }

                    })
                }
                else {
                    cell.firstIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId]

                }
                
            }
            else{
                cell.firstIV.image = playerImagesInGameDic[game.gameId!]![0].image
            }
            
            if playerImagesInGameDic[game.gameId!]![1].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId] == nil {
                    helper.loadUserProfilePicture(userId: playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.secondIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.secondIV.image = image
                            }
                        }
                    })
                }
                else{
                    cell.secondIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId]
                }
            }
            else{
                cell.secondIV.image = playerImagesInGameDic[game.gameId!]![1].image
            }
        }
        else if let game = game as? GameJSONModel {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            
            if playerImagesInGameDic[game.gameId]![0].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId] == nil {
                    helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                  
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.firstIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] = image
                 
                            DispatchQueue.main.async {
                                cell.firstIV.image = image
                            }
                        }
                    })
                }
                else{
                    cell.firstIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId]
                }
            }
            else{
                cell.firstIV.image = playerImagesInGameDic[game.gameId]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![1].imageEmpty{
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId] == nil {
                    helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.secondIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId]
                            }
                        }
                        else {
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.secondIV.image = image
                            }
                        }
                    })
                }
                else {
                    cell.secondIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId]
                }
            }
            else{
                cell.secondIV.image = self.playerImagesInGameDic[game.gameId]![1].image
            }
        }
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        return cell
    }
    
    func loadThreeImagesCell(cell: PreviewGamesThreeImageCell, game:Any, indexPath: IndexPath) -> PreviewGamesThreeImageCell {
        let cell = CellAnimator.add(cell: cell)
        
        if selectedAll {
            cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
        }
        else{
            if selectedIndexPath[indexPath] == true {
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else{
                cell.accessoryType = cell.isSelected ? .checkmark : .none
            }
        }
        
        cell.selectionStyle = .none
        cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = UIImageViewHelper.roundImageView(imageview: cell.thirdIV, radius: 5)
        
        if let game = game as? Game {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.players?.allObjects as? [Player]
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
            
            if playerImagesInGameDic[game.gameId!]![0].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId] == nil {
                    helper.loadUserProfilePicture(userId: playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.firstIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.firstIV.image = image
                            }
                        }
                    })
                }
                else {
                    cell.firstIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId]
                }
            }
            else{
                cell.firstIV.image = playerImagesInGameDic[game.gameId!]![0].image
            }
            
            if playerImagesInGameDic[game.gameId!]![1].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId] == nil {
                    helper.loadUserProfilePicture(userId: playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.secondIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.secondIV.image = image
                            }
                        }
                    })
                }
                else{
                    cell.secondIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId]
                }
            }
            else{
                cell.secondIV.image = playerImagesInGameDic[game.gameId!]![1].image
            }
            
            if playerImagesInGameDic[game.gameId!]![2].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![2].playerId] == nil {
                    helper.loadUserProfilePicture(userId: playerImagesInGameDic[game.gameId!]![2].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.thirdIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId]
                            }
                        }
                        else {
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.thirdIV.image = image
                            }
                        }
                    })
                }
                else{
                    cell.thirdIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId]
                }
            }
            else{
                cell.thirdIV.image = playerImagesInGameDic[game.gameId!]![2].image
            }
        }
        else if let game = game as? GameJSONModel {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            if playerImagesInGameDic[game.gameId]![0].imageEmpty {
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId] == nil {
                    helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.firstIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            self.playerImagesInGameDic[game.gameId]![0].image = image
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![0].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.firstIV.image = image
                            }
                        }
                    })
                }
                else{
                    cell.firstIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![0].playerId]
                }
            }
            else{
                cell.firstIV.image = playerImagesInGameDic[game.gameId]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![1].imageEmpty{
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId] == nil {
                    helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.secondIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId]
                            }
                        }
                        else {
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![1].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.secondIV.image = image
                            }
                        }
                    })
                }
                else {
                    cell.secondIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![1].playerId]
                }
            }
            else{
                cell.secondIV.image = self.playerImagesInGameDic[game.gameId]![1].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![2].imageEmpty{
                if imageDownloaded[playerImagesInGameDic[game.gameId!]![2].playerId] == nil {
                    helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![2].playerId, completeHandler: { (imageData) in
                        
                        if self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId] != nil {
                            DispatchQueue.main.async {
                                cell.thirdIV.image = self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId]
                            }
                        }
                        else{
                            var image = UIImage(data: imageData)
                            image = UIImage(data: (image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            self.imageDownloaded[self.playerImagesInGameDic[game.gameId!]![2].playerId] = image
                            
                            DispatchQueue.main.async {
                                cell.thirdIV.image = image
                            }
                        }
                    })
                }
                else {
                    cell.thirdIV.image = imageDownloaded[playerImagesInGameDic[game.gameId!]![2].playerId]

                }
            }
            else{
                cell.thirdIV.image = self.playerImagesInGameDic[game.gameId]![2].image
            }
        }
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        return cell
    }
    
    func loadFourImagesCell(cell: PreviewGamesFourImageCell, game:Any, indexPath: IndexPath) -> PreviewGamesFourImageCell {
        let cell = CellAnimator.add(cell: cell)
        
        if selectedAll {
            cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
        }
        else{
            if selectedIndexPath[indexPath] == true {
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else{
                cell.accessoryType = cell.isSelected ? .checkmark : .none
            }
        }
        
        cell.selectionStyle = .none
        cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = UIImageViewHelper.roundImageView(imageview: cell.thirdIV, radius: 5)
        cell.fourthIV = UIImageViewHelper.roundImageView(imageview: cell.fourthIV, radius: 5)
        
        if let game = game as? Game {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.players?.allObjects as? [Player]
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
            
            
        }
        else if let game = game as? GameJSONModel {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            
        }
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        return cell
    }
}
