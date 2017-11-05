
//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviousGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    var playerImagesInGameDic = [String:[String:UIImage]]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Game!
    var gameModels = [String:MememeDBObjectModel]()
    
    var sections = [PreviewSection]()
    var firstTimeLoading = true
    
    let helper = UserFilesHelper()
    
    var playerImageDownload = [String:UIImage]()
    
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
        
                var x = 0
                self.gameModels.removeAll()
                
                for model in models!{
                    let game = GameDataFromJSON.getGameFromJSON(model: model)
                    self.gameModels[game.gameId!] = model
                    
                    var playersImages = [String:UIImage]()

                    let players = game.players?.allObjects as? [Player]
                    
                    for player in players!{
                        let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                        if image != #imageLiteral(resourceName: "ichooseyou"){
                            playersImages[player.playerId!] = image
                        }
                        else{
                            playersImages[player.playerId!] = #imageLiteral(resourceName: "ichooseyou")
                        }
                    }
                    
                    self.playerImagesInGameDic[game.gameId!] = playersImages
                    
                    if(self.gamesStorageLocation[game.gameId!] == nil){
                        self.putGameIntoRightSection(game: game)
                        self.gamesStorageLocation[game.gameId!] = "dynamodb"
                    }
                    x = x + 1
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
                
                var playersImages = [String:UIImage]()
                var temp = [String:Bool]()
                
                for player in (object.players?.allObjects as? [Player])!{
                    let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                    
                    if temp[player.playerId!] == nil || temp[player.playerId!] == false {
                        if image != #imageLiteral(resourceName: "ichooseyou"){
                            playersImages[player.playerId!] = image
                        }
                        else {
                            playersImages[player.playerId!] = #imageLiteral(resourceName: "ichooseyou")
                        }
                        temp[player.playerId!] = true
                    }
                }
                self.playerImagesInGameDic[object.gameId!] = playersImages
            }
        }
        sortDataAndReloadTableView()
    }
    
    private func sortDataAndReloadTableView(){
        for section in sections {
            if !section.changed {
                return
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
            destination.playerImageDic = playerImagesInGameDic[gameForSegue.gameId!]!
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
