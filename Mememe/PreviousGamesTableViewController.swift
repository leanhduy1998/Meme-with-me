//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviousGamesTableViewController: UITableViewController {
    var games = [Game]()
    var playerImagesInGameDic = [String:[UIImage]]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GameStack.sharedInstance.initializeFetchedResultsController()
        
        let fetchedObjects = GameStack.sharedInstance.fetchedResultsController.fetchedObjects as? [Game]
        
        for object in fetchedObjects!{
            if(gamesStorageLocation[object.gameId!]==nil){
                gamesStorageLocation[object.gameId!] = "coreData"
                games.append(object)
            }
        }
        
        /*MememeDynamoDB.queryWithMyPlayerIdWithCompletionHandler(userId: MyPlayerData.id) { (result, error) in
            
            DispatchQueue.main.async {
                let gameModels = result?.items as? [MememeDBObjectModel]
                
                var count = 0
                var playersImages = [UIImage]()
                
                for model in gameModels!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    
                    //userId here is playerId
                    if(self.gamesStorageLocation[game.gameId!] == nil){
                        self.gamesStorageLocation[game.gameId!] = "internet"
                   
                        self.games.append(game)
                        
                        let players = game.players?.allObjects as? [Player]
                        
                        count = 0
                        for player in players!{
                            if(count == 4){
                                break
                            }
                            var image: UIImage!
                            if(player.userImageData == nil){
                                let helper = UserFilesHelper()
                                helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (userImageData) in
                                    DispatchQueue.main.async {
                                        image = UIImage(data: userImageData as! Data)
                                        var newImage:UIImage!
                                        let emptyCell = AvailableGamesNoImageCell()
                                    
                                        let size = CGSize(width: 65, height: 65)
                                        UIGraphicsBeginImageContextWithOptions(size, true, 0);
                                        image?.draw(in: CGRect(x:0,y:0,width:size.width, height:size.height))
                                        newImage = UIGraphicsGetImageFromCurrentImageContext()!
                                        UIGraphicsEndImageContext()
                                        
                                        var found = false
                                        for i in playersImages{
                                            if(i == newImage){
                                                found = true
                                            }
                                        }
                                        
                                        if(!found){
                                            playersImages.append(newImage)
                                        }
                                        
                                        self.playerImagesInGameDic[game.gameId!] = playersImages
                                        
                                        if(count == (players?.count)!-1){
                                            self.tableView.reloadData()
                                            return
                                        }
                                        else{
                                            count = count + 1
                                        }
                                    }
                                })
                            }
                            else{
                                image = UIImage(data: player.userImageData as! Data)
                                var newImage:UIImage!
                                let emptyCell = AvailableGamesNoImageCell()
                                
                                let size = CGSize(width: emptyCell.firstIV.frame.width, height: emptyCell.firstIV.frame.height)
                                UIGraphicsBeginImageContextWithOptions(size, true, 0)
                                image?.draw(in: CGRect(x:0,y:0,width:size.width, height:size.height))
                                newImage = UIGraphicsGetImageFromCurrentImageContext()!
                                UIGraphicsEndImageContext()
                                
                                var found = false
                                for i in playersImages{
                                    if(i == newImage){
                                        found = true
                                    }
                                }
                                
                                if(!found){
                                    playersImages.append(newImage)
                                }
                                
                                count = count + 1
                                
                                self.playerImagesInGameDic[game.gameId!] = playersImages
                            }
                        }

                        
                    }
                }
                if(gameModels?.count == self.playerImagesInGameDic.count){
                    self.tableView.reloadData()
                    return
                }
            }
        }*/
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numberOfGames = games.count
        return numberOfGames
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesNoImageCell") as? AvailableGamesNoImageCell)!
        cell = CellAnimator.add(cell: cell)
        
        let game = games[indexPath.row]
        
        let players = game.players?.allObjects as? [Player]
        
        var playersImages = [UIImage]()
        
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            for player in (game.players?.allObjects as? [Player])! {
                playersImages.append(UIImage(data: player.userImageData! as Data)!)
            }
        }
        else{
            if(playerImagesInGameDic[game.gameId!] == nil){
                for player in (game.players?.allObjects as? [Player])!{
                    playerImagesInGameDic[game.gameId!] = [UIImage]()
                    playerImagesInGameDic[game.gameId!]?.append(UIImage())
                }
            }
            playersImages = playerImagesInGameDic[game.gameId!]!
        }
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        if(playersImages == nil){
            return cell
        }
        
        
        switch(playersImages.count){
        case 1:
            cell.secondIV.image = playersImages[0]
            break
        case 2:
            cell.secondIV.image = playersImages[0]
            cell.thirdIV.image = playersImages[1]
            break
        case 3:
            cell.firstIV.image = playersImages[0]
            cell.secondIV.image = playersImages[1]
            cell.thirdIV.image = playersImages[2]
            break
        case 4:
            cell.firstIV.image = playersImages[0]
            cell.secondIV.image = playersImages[1]
            cell.thirdIV.image = playersImages[2]
            cell.fourthIV.image = playersImages[3]
            break
        default:
            if(playersImages.count>4){
                cell.firstIV.image = playersImages[0]
                cell.secondIV.image = playersImages[1]
                cell.thirdIV.image = playersImages[2]
                cell.fourthIV.image = playersImages[3]
            }
            break
        }
        cell.activityIndicator.stopAnimating()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameForSegue = games[indexPath.row]
        performSegue(withIdentifier: "PreviewInGameViewControllerSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PreviewInGameViewController{
            destination.game = gameForSegue
        }
    }
    

}
