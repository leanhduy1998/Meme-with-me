
//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviousGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    var playerImagesInGameDic = [String:[PreviewImage]]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Any!
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
                    let game = GameDataFromJSON.getGameJSONModelFromJSON(model: model)
                    self.gameModels[game.gameId!] = model
                    
                    if self.playerImagesInGameDic[game.gameId!] == nil {
                        self.playerImagesInGameDic[game.gameId!] = [PreviewImage]()
                    }

                    let players = game.player
                    for player in players{
                        var image = FileManagerHelper.getImageFromMemory(imagePath: player.userImageLocation!)
                        
                        let previewImage = PreviewImage(image: image, playerId: player.playerId!)
                        
                        if image != #imageLiteral(resourceName: "ichooseyou") {
                            image = UIImageEditor.resizeImage(image: image, targetSize: CGSize(width: 90, height: 90))
                        }
                        else{
                            previewImage.imageEmpty = true
                        }
                        self.playerImagesInGameDic[game.gameId!]?.append(previewImage)
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
                
                if playerImagesInGameDic[object.gameId!] == nil {
                    playerImagesInGameDic[object.gameId!] = [PreviewImage]()
                }
                
                for player in (object.players?.allObjects as? [Player])!{
                    var image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                    
                    let previewImage = PreviewImage(image: image, playerId: player.playerId!)
                    
                    if image != #imageLiteral(resourceName: "ichooseyou") {
                        image = UIImageEditor.resizeImage(image: image, targetSize: CGSize(width: 90, height: 90))
                    }
                    else {
                        previewImage.imageEmpty = true
                    }
                    playerImagesInGameDic[object.gameId!]?.append(previewImage)
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
                if let g1 = game1 as? Game{
                    if let g2 = game2 as? Game {
                        return g1.createdDate! as Date > g2.createdDate! as Date
                    }
                    else if let g2 = game2 as? GameJSONModel{
                        return g1.createdDate! as Date > g2.createdDate
                    }
                }
                else if let g1 = game1 as? GameJSONModel {
                    if let g2 = game2 as? Game {
                        return g1.createdDate > g2.createdDate! as Date
                    }
                    else if let g2 = game2 as? GameJSONModel{
                        return g1.createdDate! > g2.createdDate
                    }
                }
                return false
            }
        }
    }
    
    private func putGameIntoRightSection(game:Any){
        var gameDateInt: Int!
        if let game = game as? Game {
            gameDateInt = GetGameData.getDateInt(date: game.createdDate! as Date)
        }
        else if let game = game as? GameJSONModel {
            gameDateInt = GetGameData.getDateInt(date: game.createdDate!)
        }
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
        }

    }
}
