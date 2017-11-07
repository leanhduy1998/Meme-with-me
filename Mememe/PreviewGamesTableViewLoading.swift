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
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        
        cell.firstIV.image = playerImagesDic[players![0].playerId!]
        cell.secondIV.image = playerImagesDic[players![1].playerId!]
        self.sections[indexPath.section].finishLoading = true
        
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
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        
        cell.firstIV.image = playerImagesDic[players![0].playerId!]
        cell.secondIV.image = playerImagesDic[players![1].playerId!]
        cell.thirdIV.image = playerImagesDic[players![2].playerId!]
        self.sections[indexPath.section].finishLoading = true
        
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
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        cell.fourthIV = CircleImageCutter.roundImageView(imageview: cell.fourthIV, radius: 5)
        
        
        cell.firstIV.image = playerImagesDic[players![0].playerId!]
        cell.secondIV.image = playerImagesDic[players![1].playerId!]
        cell.thirdIV.image = playerImagesDic[players![2].playerId!]
        cell.fourthIV.image = playerImagesDic[players![3].playerId!]
        self.sections[indexPath.section].finishLoading = true
        
        return cell
    }
}
