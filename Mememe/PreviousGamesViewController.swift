
//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviousGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    var playerImagesDic = [String:UIImage]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Game!
    var gameModels = [String:MememeDBObjectModel]()
    
    var sections = [PreviewSection]()
    var firstTimeLoading = true
    
    let helper = UserFilesHelper()
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetGameData.getTimeIntForPreviewTable { (timeArr, currentTimeInt) in
            DispatchQueue.main.async {
                self.setupSections(timeArr: timeArr, currentTimeInt: currentTimeInt)

                self.firstTimeLoading = false
                if(Reachability.isConnectedToNetwork()){
                    self.addDynamoDBDataToGames()
                }
                else{
                    self.addCoreDataToGames()
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!firstTimeLoading && Reachability.isConnectedToNetwork()){
            addDynamoDBDataToGames()
        }
    }
    
    private func addDynamoDBDataToGames(){
        addCoreDataToGames()
        self.queryAndHandleData(completeHandler: {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        })
        
    }
    private func queryAndHandleData(completeHandler: @escaping ()-> Void){
        MememeDynamoDB.queryWithMyPlayerIdWithCompletionHandler(userId: MyPlayerData.id) { (result, error) in
            
            DispatchQueue.main.async {
                let models = result?.items as? [MememeDBObjectModel]
        
                self.gameModels.removeAll()
                
                for model in models!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    self.gameModels[game.gameId!] = model
        

                    let players = game.players?.allObjects as? [Player]
                    for player in players!{
                        if self.playerImagesDic[player.playerId!] == nil {
                            self.helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (imageData) in
                                DispatchQueue.main.async {
                                    self.playerImagesDic[player.playerId!] = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                                }
                            })
                        }
                    }
                    
                    if(self.gamesStorageLocation[game.gameId!] == nil){
                        self.putGameIntoRightSection(game: game)
                        self.gamesStorageLocation[game.gameId!] = "dynamodb"
                    }
                }
                self.sortDataAndReloadTableView()
                completeHandler()
            }
        }
    }
    
    private func addCoreDataToGames(){
        GameStack.sharedInstance.initializeFetchedResultsController()
        let fetchedObjects = GameStack.sharedInstance.fetchedResultsController.fetchedObjects as? [Game]
        
        for object in fetchedObjects!{
            if(gamesStorageLocation[object.gameId!]==nil){
                gamesStorageLocation[object.gameId!] = "coreData"
                putGameIntoRightSection(game: object)
                
                if(Reachability.isConnectedToNetwork()){
                    for player in (object.players?.allObjects as? [Player])!{
                        if playerImagesDic[player.playerId!] == nil {
                            self.helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (imageData) in
                                DispatchQueue.main.async {
                                    self.playerImagesDic[player.playerId!] = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                                }
                            })
                        }
                    }
                }
                else{
                    for player in (object.players?.allObjects as? [Player])!{
                        if playerImagesDic[player.playerId!] == nil {
                            let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                            playerImagesDic[player.playerId!] = image
                        }
                    }
                }
            }
        }
        sortDataAndReloadTableView()
    }
    
    private func sortDataAndReloadTableView(){
        for section in sections {
            if !section.changed {
                continue
            }
            section.changed = false
            
            section.games = section.games.sorted { (game1, game2) -> Bool in
                return game1.createdDate! as Date > game2.createdDate! as Date
            }
        }
    }
    
    private func putGameIntoRightSection(game:Game){
        let gameDateInt = GetGameData.getDateInt(date: game.createdDate! as Date)
        
        if gameDateInt > sections[0].fromInt {
            sections[0].games.append(game)
            return
        }
        
        for section in sections{
            if gameDateInt <= section.fromInt && gameDateInt >= section.toInt{
                section.games.append(game)
                section.changed = true
                return
            }
        }
    }
    
    func downloadBtnPressed(sender: UIButton){
        //...
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PreviewInGameViewController{
            destination.game = gameForSegue
            var dic = [String:UIImage]()
            
            for player in (gameForSegue.players?.allObjects as? [Player])!{
                dic[player.playerId!] = playerImagesDic[player.playerId!]
            }
            destination.playerImageDic = dic
        }
        if segue.destination is AvailableGamesViewController{
            for section in sections {
                for game in section.games {
                    if(gamesStorageLocation[game.gameId!] == "dynamodb"){
                        GameStack.sharedInstance.stack.context.delete(game)
                    }
                }
            }
        }
    }
}
