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
        
     //   let cell = CellAnimator.add(cell: cell)
        cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 5)
        
        if let game = game as? Game {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
            }
            
            let players = game.players?.allObjects as? [Player]
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
            
            if self.playerImagesInGameDic[game.gameId!]![0].imageEmpty {
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    self.playerImagesInGameDic[game.gameId!]![0].image = image
                    self.playerImagesInGameDic[game.gameId!]![0].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.firstIV.image = image
                        //self.tableview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                })
            }
            else{
                cell.firstIV.image = self.playerImagesInGameDic[game.gameId!]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId!]![1].imageEmpty {
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    self.playerImagesInGameDic[game.gameId!]![1].image = image
                    self.playerImagesInGameDic[game.gameId!]![1].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.secondIV.image = image
                       // self.tableview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                })
            }
            else{
                cell.secondIV.image = self.playerImagesInGameDic[game.gameId!]![1].image
            }
        }
        else if let game = game as? GameJSONModel {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            
            if self.playerImagesInGameDic[game.gameId]![0].imageEmpty {

                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                    
                    let image = UIImage(data: imageData)
                    self.playerImagesInGameDic[game.gameId]![0].image = image
                    self.playerImagesInGameDic[game.gameId!]![0].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.firstIV.image = image
                      //  self.tableview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                })
            }
            else{
                cell.firstIV.image = self.playerImagesInGameDic[game.gameId]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![1].imageEmpty{
                DispatchQueue.main.async {
                    self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                        
                        let image = UIImage(data: imageData)
                        self.playerImagesInGameDic[game.gameId]![1].image = image
                        self.playerImagesInGameDic[game.gameId!]![1].imageEmpty = false
                        
                        DispatchQueue.main.async {
                            cell.secondIV.image = image
                      //      self.tableview.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        }
                    })
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
     //   let cell = CellAnimator.add(cell: cell)
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
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
            }
            
            let players = game.players?.allObjects as? [Player]
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
            
            if self.playerImagesInGameDic[game.gameId!]![0].imageEmpty{
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId!]![0].image = image
                    self.playerImagesInGameDic[game.gameId!]![0].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.firstIV.image = image
                    }
                })
            }
            else{
                cell.firstIV.image = self.playerImagesInGameDic[game.gameId!]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId!]![1].imageEmpty {
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId!]![1].image = image
                    self.playerImagesInGameDic[game.gameId!]![1].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.secondIV.image = image
                    }
                })
            }
            else{
                cell.secondIV.image = self.playerImagesInGameDic[game.gameId!]![1].image
            }
            
            if self.playerImagesInGameDic[game.gameId!]![2].imageEmpty {
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![2].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId!]![2].image = image
                    self.playerImagesInGameDic[game.gameId!]![2].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.thirdIV.image = image
                    }
                })
            }
            else{
                cell.thirdIV.image = self.playerImagesInGameDic[game.gameId!]![0].image
            }
        }
        else if let game = game as? GameJSONModel {
            if(gamesStorageLocation[game.gameId!]! == "coreData"){
                cell.downloadBtn.isHidden = true
            }
            else{
                cell.downloadBtn.isHidden = false
                cell.downloadBtn.tag = indexPath.row
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            if self.playerImagesInGameDic[game.gameId]![0].imageEmpty {

                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![0].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId]![0].image = image
                    self.playerImagesInGameDic[game.gameId!]![0].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.firstIV.image = image
                    }
                })
            }
            else{
                cell.firstIV.image = self.playerImagesInGameDic[game.gameId]![0].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![1].imageEmpty {
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![1].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId]![1].image = image
                    self.playerImagesInGameDic[game.gameId!]![1].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.secondIV.image = image
                    }
                })
            }
            else{
                cell.secondIV.image = self.playerImagesInGameDic[game.gameId]![1].image
            }
            
            if self.playerImagesInGameDic[game.gameId]![2].imageEmpty {
    
                self.helper.loadUserProfilePicture(userId: self.playerImagesInGameDic[game.gameId!]![2].playerId, completeHandler: { (imageData) in
                    
                    var image = UIImage(data: imageData)
                    image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                    
                    self.playerImagesInGameDic[game.gameId]![2].image = image
                    self.playerImagesInGameDic[game.gameId!]![2].imageEmpty = false
                    
                    DispatchQueue.main.async {
                        cell.thirdIV.image = image
                    }
                })
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
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
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
                
                cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
            }
            
            let players = game.player
            
            cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players)
            
        }
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        return cell
    }
}
