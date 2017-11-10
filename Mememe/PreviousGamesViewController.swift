
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
  //  let cellHoldOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    var downloadAlertAction: UIAlertAction!
    
    // selecting mode
    @IBOutlet weak var cancelBarBtn: UIBarButtonItem!
    @IBOutlet weak var downloadBarBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBarBtn: UIBarButtonItem!
    @IBOutlet weak var selectAllBarBtn: UIBarButtonItem!
    
    var selectingMode = false
    var selectedAll = false
    
    var selectedIndexPath = [IndexPath:Bool]()
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.allowsMultipleSelection = true
        //tableview.decelerationRate = 1
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.tableview.addGestureRecognizer(longPressRecognizer)

        /*
        downloadAlertAction = UIAlertAction(title: "Download To Phone", style: UIAlertActionStyle.default, handler: downloadOption)
        
        cellHoldOptionAlertController.addAction(downloadAlertAction)
        cellHoldOptionAlertController.addAction(UIAlertAction(title: "Delete Game", style: UIAlertActionStyle.default, handler: deleteOption))
        cellHoldOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))*/

        
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
    
    @IBAction func selectAllBtnPressed(_ sender: Any) {
        if selectAllBarBtn.title! == "Select All"{
            selectAllBarBtn.title = "Deselect All"
            showDownloadDeleteCancelBarBtn()
            selectingMode = true
            selectedAll = true
            for cell in tableview.visibleCells {
                cell.accessoryType = .checkmark
            }
        }
        else {
            selectAllBarBtn.title = "Select All"
            hideDownloadDeleteCancelBarBtn()
            selectingMode = false
            selectedAll = false
            for cell in tableview.visibleCells {
                cell.accessoryType = .none
            }
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        if(!Reachability.isConnectedToNetwork()){
            DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
            return
        }
        
        hideDownloadDeleteCancelBarBtn()
        selectingMode = false
        
        if selectedAll {
            selectedIndexPath.removeAll()
            for section in sections {
                for game in section.games {
                    if let game = game as? Game {
                        GameStack.sharedInstance.stack.context.delete(game)
                        
                        MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                            if error == nil {
                                DispatchQueue.main.async {
                                    self.tableview.reloadData()
                                }
                            }
                        })
                    }
                    else if let game = game as? GameJSONModel{
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
            }
        }
        else{
            for (indexPath,_) in selectedIndexPath {
                if let game = sections[indexPath.section].games[indexPath.row] as? Game {
                    GameStack.sharedInstance.stack.context.delete(game)
                    GameStack.sharedInstance.saveContext {}
                    
                    if game.gameId == nil || gameModels[game.gameId!] == nil {
                        self.sections[indexPath.section].games.remove(at: indexPath.row)
                        self.selectedIndexPath.removeValue(forKey: indexPath)
                        self.tableview.reloadData()
                        continue
                    }
                    
                    MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.sections[indexPath.section].games.remove(at: indexPath.row)
                                self.gameModels.removeValue(forKey: game.gameId!)
                                self.selectedIndexPath.removeValue(forKey: indexPath)
                                self.tableview.reloadData()
                            }
                        }
                    })
                }
                else if let game = sections[indexPath.section].games[indexPath.row] as? GameJSONModel{
                    MememeDynamoDB.removeItem(game.model, completionHandler: { (error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.sections[indexPath.section].games.remove(at: indexPath.row)
                                self.gameModels.removeValue(forKey: game.gameId!)
                                self.selectedIndexPath.removeValue(forKey: indexPath)
                                self.tableview.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func downloadBtnPressed(_ sender: Any) {
        if(!Reachability.isConnectedToNetwork()){
            DisplayAlert.display(controller: self, title: "There's a bug in my pants", message: "You can't download games unless there is wifi! Sorry!")
            return
        }
        
        var unableToDownloadCounts = 0
        
        if selectedAll {
            
            for section in sections {
                for game in section.games {
                    if game is Game{
                        unableToDownloadCounts = unableToDownloadCounts + 1
                        continue
                    }
                    var gameModel = game as? GameJSONModel
                    gamesStorageLocation[(gameModel?.gameId!)!]! = "coreData"
                    
                    GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                        gameModel = nil
                    })
                }
            }
            tableview.reloadData()
        }
        else {
            for (indexPath,_) in selectedIndexPath {
                if sections[indexPath.section].games[indexPath.row] is Game{
                    unableToDownloadCounts = unableToDownloadCounts + 1
                    continue
                }
                var gameModel = sections[indexPath.section].games[indexPath.row] as? GameJSONModel
                
                switch((gameModel?.player.count)!){
                case 1:
                    break
                case 2:
                    let cell = tableview.cellForRow(at: indexPath) as? PreviewGamesTwoImageCell
                    if cell?.downloadBtn.isHidden == true {
                        unableToDownloadCounts = unableToDownloadCounts + 1
                        continue
                    }
                    
                    cell?.downloadBtn.isHidden = true
                    cell?.activityIndicator.startAnimating()
                    GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                        gameModel = nil
                        DispatchQueue.main.async {
                            cell?.activityIndicator.stopAnimating()
                            self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                            self.tableview.reloadRows(at: [indexPath], with: .fade)
                        }
                    })
                    break
                case 3:
                    let cell = tableview.cellForRow(at: indexPath) as? PreviewGamesThreeImageCell
                    if cell?.downloadBtn.isHidden == true {
                        unableToDownloadCounts = unableToDownloadCounts + 1
                        continue
                    }
                    cell?.activityIndicator.startAnimating()
                    GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                        gameModel = nil
                        DispatchQueue.main.async {
                            cell?.activityIndicator.stopAnimating()
                            self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                            self.tableview.reloadRows(at: [indexPath], with: .fade)
                        }
                    })
                    break
                default:
                    let cell = tableview.cellForRow(at: indexPath) as? PreviewGamesFourImageCell
                    if cell?.downloadBtn.isHidden == true {
                        unableToDownloadCounts = unableToDownloadCounts + 1
                        continue
                    }
                    cell?.activityIndicator.startAnimating()
                    GameDataFromJSON.saveGameCoreDataFromJSON(model: (gameModel?.model)!, completeHandler: {
                        gameModel = nil
                        DispatchQueue.main.async {
                            cell?.activityIndicator.stopAnimating()
                            self.gamesStorageLocation[(gameModel?.gameId)!] = "coreData"
                            self.tableview.reloadRows(at: [indexPath], with: .fade)
                        }
                    })
                    break
                }
            }
        }
        if unableToDownloadCounts == 0 {
            DisplayAlert.display(controller: self, title: "All sets!", message: "All selected games are being download!")
        }
        else {
            DisplayAlert.display(controller: self, title: "Hmmm", message: "Some games are already on your phone!")
        }
    }
    
    @IBAction func cancelBtnBarPressed(_ sender: Any) {
        selectAllBarBtn.title = "Select All"
        hideDownloadDeleteCancelBarBtn()
        selectingMode = false
        selectedAll = false
        for cell in tableview.visibleCells {
            cell.accessoryType = .none
        }
    }
    
    /*
    func downloadOption(action: UIAlertAction){
        print("download")
     
 
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
 */
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableview)
            if let indexPath = tableview.indexPathForRow(at: touchPoint) {
                selectingMode = true
                tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                selectedIndexPath[indexPath] = true
                showDownloadDeleteCancelBarBtn()
                
                /*
                if sections[holdedIndex.section].games[holdedIndex.row] is Game {
                    downloadAlertAction.isEnabled = false
                }
                else if sections[holdedIndex.section].games[holdedIndex.row] is GameJSONModel{
                    downloadAlertAction.isEnabled = true
                }
                present(cellHoldOptionAlertController, animated: true, completion: nil)*/
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!firstTimeLoading && Reachability.isConnectedToNetwork()){
            addDynamoDBDataToGames()
        }
        hideDownloadDeleteCancelBarBtn()
    }
    
    private func hideDownloadDeleteCancelBarBtn(){
        downloadBarBtn.title = ""
        downloadBarBtn.isEnabled = false
        cancelBarBtn.title = ""
        cancelBarBtn.isEnabled = false
        deleteBarBtn.title = ""
        deleteBarBtn.isEnabled = false
    }
    private func showDownloadDeleteCancelBarBtn(){
        downloadBarBtn.title = "Download"
        downloadBarBtn.isEnabled = true
        cancelBarBtn.title = "Cancel"
        cancelBarBtn.isEnabled = true
        deleteBarBtn.title = "Delete"
        deleteBarBtn.isEnabled = true
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
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PreviewInGameViewController{
            destination.game = gameForSegue     
        }

    }
}
