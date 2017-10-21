
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
                
                for model in gameModels!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    
                    var playersImages = [UIImage]()
                        
                    let players = game.players?.allObjects as? [Player]
                    
                    var count = 0
                    for player in players!{
                        let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                        /*var newImage:UIImage!
                        let emptyCell = AvailableGamesNoImageCell()
                                
                        let size = CGSize(width: emptyCell.firstIV.frame.width, height: emptyCell.firstIV.frame.height)
                        UIGraphicsBeginImageContextWithOptions(size, true, 0)
                        image.draw(in: CGRect(x:0,y:0,width:size.width, height:size.height))
                        newImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()*/
                                
                        var found = false
                        for i in playersImages{
                            if(i == image){
                                found = true
                                self.view.backgroundColor = UIColor(patternImage: image)
                            }
                        }
                        if(!found){
                            playersImages.append(image)
                            self.view.backgroundColor = UIColor(patternImage: image)
                        }
                        self.playerImagesInGameDic[game.gameId!] = playersImages
                        
                        if(count == (players?.count)!-1){
                            if(self.gamesStorageLocation[game.gameId!] == nil){
                                self.games.append(game)
                            }
                            self.gamesStorageLocation[game.gameId!] = "dynamodb"
                        }
                        
                        count = count + 1
                    }
                }
                self.tableView.reloadData()
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
                    let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
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
        
        if games.count == 0{
            return
        }
        
        for x in 0...(games.count-1){
            if(games[x] != oldGames[x]){
                tableView.reloadData()
                break
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
