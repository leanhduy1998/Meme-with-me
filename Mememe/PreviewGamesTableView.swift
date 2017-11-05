//
//  PreviewGamesTableView.swift
//  Mememe
//
//  Created by Duy Le on 11/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension PreviousGamesViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section].games.count == 0 {
            return ""
        }
        return sections[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.section].finishLoading{
            gameForSegue = sections[indexPath.section].games[indexPath.row]
            performSegue(withIdentifier: "PreviewInGameViewControllerSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(!Reachability.isConnectedToNetwork()){
                DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
                return
            }
            
            let game = sections[indexPath.section].games[indexPath.row]
            GameStack.sharedInstance.stack.context.delete(game)
            sections[indexPath.section].games.remove(at: indexPath.row)
            
            if gameModels[game.gameId!] == nil {
                self.tableview.reloadData()
                return
            }
            MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            })
        }
    }
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let game = sections[indexPath.section].games[indexPath.row]
        
        if indexPath.section == tableview.visibleCells.last.index
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = sections[indexPath.section].games[indexPath.row]
        
        switch((game.players?.count)!){
        case 1:
            return UITableViewCell()
            
        case 2:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesTwoImageCell") as? PreviewGamesTwoImageCell)!
            return loadTwoImagesCell(cell: cell, game: game, indexPath: indexPath)
            
        case 3:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesThreeImageCell") as? PreviewGamesThreeImageCell)!
            return loadThreeImagesCell(cell: cell, game: game, indexPath: indexPath)
            
        default:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesFourImageCell") as? PreviewGamesFourImageCell)!
            return loadFourImagesCell(cell: cell, game: game, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].games.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let players = sections[indexPath.section].games[indexPath.row].players?.allObjects as? [Player]
            
            let game = sections[indexPath.section].games[indexPath.row]
            var playersImages = playerImagesInGameDic[game.gameId!]!
            
            var ivOrder = Array(playersImages.keys)
            
            if playersImages[ivOrder[0]] == #imageLiteral(resourceName: "ichooseyou") {
                if playerImageDownload[ivOrder[0]] == nil {
                    helper.loadUserProfilePicture(userId: ivOrder[0], completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            playersImages[ivOrder[0]] = compressedImage
                        }
                    })
                }
                else{
                    playersImages[ivOrder[0]] = playerImageDownload[ivOrder[0]]
                }
            }
            
            if playersImages[ivOrder[1]] == #imageLiteral(resourceName: "ichooseyou") {
                if playerImageDownload[ivOrder[1]] == nil {
                    helper.loadUserProfilePicture(userId: ivOrder[1], completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            playersImages[ivOrder[1]] = compressedImage
                            self.playerImageDownload[ivOrder[1]] = compressedImage
                        }
                    })
                }
                else {
                    playersImages[ivOrder[1]] = playerImageDownload[ivOrder[1]]
                }
            }
            
            if players?.count == 3 && playersImages[ivOrder[2]] == #imageLiteral(resourceName: "ichooseyou") {
                if playerImageDownload[ivOrder[2]] == nil {
                    helper.loadUserProfilePicture(userId: ivOrder[2], completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            playersImages[ivOrder[2]] = compressedImage
                            self.playerImageDownload[ivOrder[2]] = compressedImage
                        }
                    })
                }
                else{
                    playersImages[ivOrder[2]] = playerImageDownload[ivOrder[2]]
                }
            }
            
            if (players?.count)! >= 4  && playersImages[ivOrder[3]] == #imageLiteral(resourceName: "ichooseyou") {
                if playerImageDownload[ivOrder[3]] == nil {
                    helper.loadUserProfilePicture(userId: ivOrder[3], completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            let compressedImage = UIImage(data:(image?.jpeg(UIImage.JPEGQuality.lowest))!)
                            playersImages[ivOrder[3]] = compressedImage
                            self.playerImageDownload[ivOrder[3]] = compressedImage
                        }
                    })
                }
                else{
                    playersImages[ivOrder[3]] = playerImageDownload[ivOrder[3]]
                }
            }
            
            playerImagesInGameDic[game.gameId!] = playersImages
        }
    }
}
