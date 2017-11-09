
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
    var imageDownloaded = [String:UIImage]()
    
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Any!
    var gameModels = [String:MememeDBObjectModel]()
    
    var sections = [PreviewSection]()
    var firstTimeLoading = true
    
    let helper = UserFilesHelper()
    
    
    // long hold in cell stuffs
    let cellHoldOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    var downloadAlertAction: UIAlertAction!
    var holdedIndex:IndexPath!
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableview.decelerationRate = 1
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        downloadAlertAction = UIAlertAction(title: "Download To Phone", style: UIAlertActionStyle.default, handler: downloadOption)
        
        cellHoldOptionAlertController.addAction(downloadAlertAction)
        cellHoldOptionAlertController.addAction(UIAlertAction(title: "Delete Game", style: UIAlertActionStyle.default, handler: deleteOption))
        cellHoldOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        
        GetGameData.getTimeIntForPreviewTable { (timeArr, currentTimeInt) in
            self.setupSections(timeArr: timeArr, currentTimeInt: currentTimeInt)
            self.firstTimeLoading = false
            
            DispatchQueue.main.async {
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
    
    func downloadOption(action: UIAlertAction){
        print("download")
        var gameModel = sections[holdedIndex.section].games[holdedIndex.row] as? GameJSONModel
        
        switch((gameModel?.player.count)!){
            case 1:
            break
            case 2:
                let cell = tableview.cellForRow(at: holdedIndex) as? PreviewGamesTwoImageCell
                cell?.downloadBtn.isHidden = true
                cell?.activityIndicator.startAnimating()
                GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                    gameModel = nil
                    DispatchQueue.main.async {
                        cell?.activityIndicator.stopAnimating()
                        self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                    }
                })
            break
            case 3:
                let cell = tableview.cellForRow(at: holdedIndex) as? PreviewGamesThreeImageCell
                cell?.downloadBtn.isHidden = true
                cell?.activityIndicator.startAnimating()
                GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                    gameModel = nil
                    DispatchQueue.main.async {
                        cell?.activityIndicator.stopAnimating()
                        self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                    }
                })
            break
            default:
                let cell = tableview.cellForRow(at: holdedIndex) as? PreviewGamesFourImageCell
                cell?.downloadBtn.isHidden = true
                cell?.activityIndicator.startAnimating()
                GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                    gameModel = nil
                    DispatchQueue.main.async {
                        cell?.activityIndicator.stopAnimating()
                        self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                    }
                })
            break
        }
        
        
        
    }
    func deleteOption(action: UIAlertAction){
        if(!Reachability.isConnectedToNetwork()){
            DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
            return
        }
        
        if let game = sections[holdedIndex.section].games[holdedIndex.row] as? Game {
            GameStack.sharedInstance.stack.context.delete(game)
            
            MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            })
        }
        else if let game = sections[holdedIndex.section].games[holdedIndex.row] as? GameJSONModel{
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
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableview)
            if let indexPath = tableview.indexPathForRow(at: touchPoint) {
                holdedIndex = indexPath
                
                if sections[holdedIndex.section].games[holdedIndex.row] is Game {
                    downloadAlertAction.isEnabled = false
                }
                else if sections[holdedIndex.section].games[holdedIndex.row] is GameJSONModel{
                    downloadAlertAction.isEnabled = true
                }
                
                present(cellHoldOptionAlertController, animated: true, completion: nil)
                // your code here, get the row for the indexPath or do whatever you want
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
                        
                    let previewImage = PreviewImage(playerId: player.playerId!)
                        
                    if image != #imageLiteral(resourceName: "ichooseyou") {
                        image = UIImageEditor.resizeImage(image: image, targetSize: CGSize(width: 90, height: 90))
                        previewImage.image = image
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
                    
                    let previewImage = PreviewImage(playerId: player.playerId!)
                    
                    if image != #imageLiteral(resourceName: "ichooseyou") {
                        image = UIImageEditor.resizeImage(image: image, targetSize: CGSize(width: 90, height: 90))
                        previewImage.image = image
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
