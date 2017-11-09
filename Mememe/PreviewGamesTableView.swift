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
        if selectingMode {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedIndexPath[indexPath] = true
        }
        else {
            gameForSegue = sections[indexPath.section].games[indexPath.row]
            performSegue(withIdentifier: "PreviewInGameViewControllerSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectingMode {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            selectedIndexPath.removeValue(forKey: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(!Reachability.isConnectedToNetwork()){
                DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
                return
            }
            
            if let game = sections[indexPath.section].games[indexPath.row] as? Game {
                GameStack.sharedInstance.stack.context.delete(game)
                
                MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.tableview.reloadData()
                        }
                    }
                })
            }
            else if let game = sections[indexPath.section].games[indexPath.row] as? GameJSONModel{
                MememeDynamoDB.removeItem(game.model, completionHandler: { (error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            if self.gameModels[game.gameId!] == nil {
                                self.tableview.reloadData()
                                return
                            }
                        }
                    }
                })
            }
            sections[indexPath.section].games.remove(at: indexPath.row)
        }
    }
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let game = sections[indexPath.section].games[indexPath.row]
        
        if indexPath.section == tableview.visibleCells.last.index
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = sections[indexPath.section].games[indexPath.row]
        
        var gameCount = 0
        
        if let game = game as? Game{
            gameCount = (game.players?.count)!
        }
        else if let game = game as? GameJSONModel{
            gameCount = game.player.count
        }
        
        switch(gameCount){
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
        /*
        for indexPath in indexPaths {
            let game = sections[indexPath.section].games[indexPath.row]
            
            if let game = game as? Game {
                let previewImages = playerImagesInGameDic[game.gameId!]
                for previewImage in previewImages! {
                    if previewImage.imageEmpty {
                        if imageDownloaded[previewImage.playerId] == nil {
                            self.helper.loadUserProfilePicture(userId: previewImage.playerId, completeHandler: { (imageData) in
                                
                                var image = UIImage(data: imageData)
                                image = UIImageEditor.resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                                
                                self.imageDownloaded[previewImage.playerId] = image
                                
                                previewImage.image = image
                                previewImage.imageEmpty = false
                            })
                        }
                        else{
                            previewImage.image = imageDownloaded[previewImage.playerId]
                        }
                    }
                }
            }
        }*/
    }
}
