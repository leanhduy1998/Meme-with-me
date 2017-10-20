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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        refreshData()
    }
    
    // the flow of data is first dynamodb, then coredata
    func refreshData(){
        if(Reachability.isConnectedToNetwork()){
            addDynamoDBDataToGames()
        }
        else{
            addCoreDataToGames()
        }
        
        
    }
    
    private func addDynamoDBDataToGames(){
        GameStack.sharedInstance.initializeFetchedResultsController()
        let fetchedObjects = GameStack.sharedInstance.fetchedResultsController.fetchedObjects as? [Game]
        
        for object in fetchedObjects!{
            if(gamesStorageLocation[object.gameId!]==nil){
                gamesStorageLocation[object.gameId!] = "coreData"
                games.append(object)
            }
        }
        
        MememeDynamoDB.queryWithMyPlayerIdWithCompletionHandler(userId: MyPlayerData.id) { (result, error) in
            
            DispatchQueue.main.async {
                let gameModels = result?.items as? [MememeDBObjectModel]
                
                var modelCount = 0
                for model in gameModels!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    
                    var playersImages = [UIImage]()
                        
                    let players = game.players?.allObjects as? [Player]
                    var count = 0
                    
                    self.gamesStorageLocation[game.gameId!] = "dynamodb"
                    
                    for player in players!{
                        var image: UIImage!
                        print(player.userImageData==nil)
                     //   if(player.userImageData == nil){
                          
                    //    }
                            /*
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
                            self.playerImagesInGameDic[game.gameId!] = playersImages
                            modelCount = modelCount + 1
                        }*/
                    }
                }
            }
        }

    }
    
    private func addCoreDataToGames(){
        GameStack.sharedInstance.initializeFetchedResultsController()
        let fetchedObjects = GameStack.sharedInstance.fetchedResultsController.fetchedObjects as? [Game]
        
        
        for object in fetchedObjects!{
            if(gamesStorageLocation[object.gameId!]==nil){
                gamesStorageLocation[object.gameId!] = "coreData"
                games.append(object)
                
                var playersImages = [UIImage]()
                for player in (object.players?.allObjects as? [Player])! {
                    var image:UIImage!
                    if(player.userImageData == nil){
                        image = UIImage()
                    }
                    else{
                        image = UIImage(data: player.userImageData! as Data)!
                    }
                
                    playersImages.append(image)
                }
                playerImagesInGameDic[object.gameId!] = playersImages
            }
        }
        sortDataAndReloadTableView()
        
    }
    private func sortDataAndReloadTableView(){
        let oldGames = games
        games = games.sorted { (game1, game2) -> Bool in
            return game1.createdDate! as Date > game2.createdDate! as Date
        }
        
        for x in 0...(games.count-1){
            if(games[x] != oldGames[x]){
                if(x >= tableView.numberOfRows(inSection: 0)){
                    self.tableView.insertRows(at: [IndexPath(row: x, section: 0)], with: UITableViewRowAnimation.left)
                    
                }
                else{
               //     print(tableView.cellForRow(at: IndexPath(row: x, section: 0)))
               //     tableView.reloadSections(NSIndexSet(index: x) as IndexSet, with: UITableViewRowAnimation.right)
                    tableView.reloadRows(at: [IndexPath(item: x, section: 0)], with: UITableViewRowAnimation.right)
                }
            }
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
            
       /*     if(playerImagesInGameDic[game.gameId!] == nil){
                for player in (game.players?.allObjects as? [Player])!{
                    playerImagesInGameDic[game.gameId!] = [UIImage]()
                    
                    let image = UIImage(data: player.userImageData! as Data)!
                    
                    var found = false
                    for i in playersImages{
                        if(image == i){
                            found = true
                        }
                    }
                    if !found {
                        playersImages.append(image)
                    }
                    
                    playerImagesInGameDic[game.gameId!]?.append(UIImage())
                }
            }*/
            playersImages = playerImagesInGameDic[game.gameId!]!
        }
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 5
        
        
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
    

}
