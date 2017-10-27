
//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import SwiftTryCatch

class PreviousGamesTableViewController: UITableViewController {
    var games = [Game]()
    var playerImagesInGameDic = [String:[UIImage]]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Game!
    
    var gameModels = [String:MememeDBObjectModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(Reachability.isConnectedToNetwork()){
            addDynamoDBDataToGames()
        }
        else{
            addCoreDataToGames(completeHandler: {})
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(Reachability.isConnectedToNetwork()){
            addDynamoDBDataToGames()
        }
    }
    
    private func addDynamoDBDataToGames(){
        addCoreDataToGames(completeHandler: {
            DispatchQueue.main.async {
                self.queryAndHandleData()
            }
        })
    }
    private func queryAndHandleData(){
        MememeDynamoDB.queryWithMyPlayerIdWithCompletionHandler(userId: MyPlayerData.id) { (result, error) in
            
            DispatchQueue.main.async {
                let models = result?.items as? [MememeDBObjectModel]
        
                var x = 0
                self.gameModels.removeAll()
                
                for model in models!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    self.gameModels[game.gameId!] = model
                    
                    var playersImages = [UIImage]()

                    let players = game.players?.allObjects as? [Player]
                    
                    for player in players!{
                        let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                        playersImages.append(image)
                    }
                    
                    self.playerImagesInGameDic[game.gameId!] = playersImages
                    
                    if(self.gamesStorageLocation[game.gameId!] == nil){
                        self.games.append(game)
                        self.gamesStorageLocation[game.gameId!] = "dynamodb"
                        
                        SwiftTryCatch.try({
                            self.tableView.insertRows(at: [IndexPath(item: x, section: 0)], with: UITableViewRowAnimation.right)
                        }, catch: { (error) in
                            self.tableView.reloadData()
                        }, finally: {
                            // close resources
                        })
                    }
                    x = x + 1
                }
            }
        }
    }
    
    private func addCoreDataToGames(completeHandler: @escaping ()-> Void){
        GameStack.sharedInstance.initializeFetchedResultsController()
        let fetchedObjects = GameStack.sharedInstance.fetchedResultsController.fetchedObjects as? [Game]
        
        for object in fetchedObjects!{
            if(gamesStorageLocation[object.gameId!]==nil || gamesStorageLocation[object.gameId!]=="dynamodb"){
                gamesStorageLocation[object.gameId!] = "coreData"
                games.append(object)
                
                var playersImages = [UIImage]()
                var temp = [String:Bool]()
                
                for player in (object.players?.allObjects as? [Player])!{
                    let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                    
                    if temp[player.playerId!] == nil || temp[player.playerId!] == false {
                        playersImages.append(image)
                        temp[player.playerId!] = true
                    }
                }
                self.playerImagesInGameDic[object.gameId!] = playersImages
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sortDataAndReloadTableView(completeHandler: completeHandler)
        }
    }
    private func sortDataAndReloadTableView(completeHandler: @escaping ()-> Void){
        let oldGames = games
        games = games.sorted { (game1, game2) -> Bool in
            return game1.createdDate! as Date > game2.createdDate! as Date
        }
        for x in 0...(games.count-1) {
            if oldGames[x] != games[x] {
                SwiftTryCatch.try({
                    self.tableView.reloadRows(at: [IndexPath(item: x, section: 0)], with: UITableViewRowAnimation.right)
                }, catch: { (error) in
                    self.tableView.reloadData()
                }, finally: {
                    // close resources
                })
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completeHandler()
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numberOfGames = games.count
        return numberOfGames
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesCell") as? PreviewGamesCell)!
        cell = CellAnimator.add(cell: cell)
        
        let game = games[indexPath.row]
        
        let players = game.players?.allObjects as? [Player]
        
        var playersImages = [UIImage]()
        
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        playersImages = playerImagesInGameDic[game.gameId!]!
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 5
        
        
        if(playersImages == nil){
            return cell
        }
        
        switch(players?.count)!{
        case 1:
            cell.secondIV.image = playersImages[0]
            break
        case 2:
            cell.secondIV.image = playersImages[0]
            cell.thirdIV.image = playersImages[1]
            break
        case 3:
            cell.secondIV.image = playersImages[1]
            cell.thirdIV.image = playersImages[2]
            cell.fourthIV.image = playersImages[0]
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
    
    func downloadBtnPressed(sender: UIButton){
        //...
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameForSegue = games[indexPath.row]
        performSegue(withIdentifier: "PreviewInGameViewControllerSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PreviewInGameViewController{
            destination.game = gameForSegue
        }
        if segue.destination is AvailableGamesViewController{
            for game in games {
                if(gamesStorageLocation[game.gameId!] == "dynamodb"){
                    GameStack.sharedInstance.stack.context.delete(game)
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(!Reachability.isConnectedToNetwork()){
                DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
                return
            }
            
            if gameModels[games[indexPath.row].gameId!] == nil {
                GameStack.sharedInstance.stack.context.delete(self.games[indexPath.row])
                games.remove(at: indexPath.row)
                self.tableView.reloadData()
                return
            }
            MememeDynamoDB.removeItem(gameModels[games[indexPath.row].gameId!]!, completionHandler: { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        GameStack.sharedInstance.stack.context.delete(self.games[indexPath.row])
                        self.games.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    

}
