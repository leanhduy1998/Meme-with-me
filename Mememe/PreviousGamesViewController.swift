
//
//  PreviousGamesTableViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviousGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var playerImagesInGameDic = [String:[UIImage]]()
    var gamesStorageLocation = [String:String]()
    var gameForSegue:Game!
    var gameModels = [String:MememeDBObjectModel]()
    
    var sections = [PreviewSection]()
    var firstTimeLoading = true
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetGameData.getTimeIntForPreviewTable { (timeArr, currentTimeInt) in
            DispatchQueue.main.async {
                self.sections.append(PreviewSection(sectionTitle: "In 24 hours", fromInt: currentTimeInt, toInt: timeArr[0]))
                self.sections.append(PreviewSection(sectionTitle: "This week", fromInt: timeArr[0], toInt: timeArr[1]))
                self.sections.append(PreviewSection(sectionTitle: "Two Weeks Ago", fromInt: timeArr[1], toInt: timeArr[2]))
                self.sections.append(PreviewSection(sectionTitle: "Three Weeks Ago", fromInt: timeArr[2], toInt: timeArr[3]))
                self.sections.append(PreviewSection(sectionTitle: "A Month Ago", fromInt: timeArr[3], toInt: timeArr[4]))
                self.sections.append(PreviewSection(sectionTitle: "Two Months Ago", fromInt: timeArr[4], toInt: timeArr[5]))
                self.sections.append(PreviewSection(sectionTitle: "Three Months Ago", fromInt: timeArr[5], toInt: timeArr[6]))
                self.sections.append(PreviewSection(sectionTitle: "Four Months Ago", fromInt: timeArr[6], toInt: timeArr[7]))
                self.sections.append(PreviewSection(sectionTitle: "Five Months Ago", fromInt: timeArr[7], toInt: timeArr[8]))
                self.sections.append(PreviewSection(sectionTitle: "Six Months Ago", fromInt: timeArr[8], toInt: timeArr[9]))
                self.sections.append(PreviewSection(sectionTitle: "Seven Months Ago", fromInt: timeArr[9], toInt: timeArr[10]))
                self.sections.append(PreviewSection(sectionTitle: "Eight Months Ago", fromInt: timeArr[10], toInt: timeArr[11]))
                self.sections.append(PreviewSection(sectionTitle: "Nine Months Ago", fromInt: timeArr[11], toInt: timeArr[12]))
                self.sections.append(PreviewSection(sectionTitle: "Ten Months Ago", fromInt: timeArr[12], toInt: timeArr[13]))
                self.sections.append(PreviewSection(sectionTitle: "Eleven Months Ago", fromInt: timeArr[13], toInt: timeArr[14]))
                self.sections.append(PreviewSection(sectionTitle: "Last Year", fromInt: timeArr[14], toInt: timeArr[15]))
                
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
                    
                    var playersImages = [UIImage]()

                    let players = game.players?.allObjects as? [Player]
                    
                    for player in players!{
                        let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                        playersImages.append(image)
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
            if(gamesStorageLocation[object.gameId!]==nil || gamesStorageLocation[object.gameId!]=="dynamodb"){
                gamesStorageLocation[object.gameId!] = "coreData"
                putGameIntoRightSection(game: object)
                
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
    
    

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].games.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = sections[indexPath.section].games[indexPath.row]
        
        let playersImages = playerImagesInGameDic[game.gameId!]!
        if(playersImages == nil){
            return UITableViewCell()
        }
        
        switch((game.players?.count)!){
            case 1:
                return UITableViewCell()
            
            case 2:
                var cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesTwoImageCell") as? PreviewGamesTwoImageCell)!
                return loadTwoImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
            
            case 3:
                var cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesThreeImageCell") as? PreviewGamesThreeImageCell)!
                return loadThreeImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
            
            default:
                var cell = (tableView.dequeueReusableCell(withIdentifier: "PreviewGamesFourImageCell") as? PreviewGamesFourImageCell)!
                return loadFourImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
        }
    }
    
    private func loadTwoImagesCell(cell: PreviewGamesTwoImageCell, playersImages:[UIImage], game:Game, indexPath: IndexPath) -> PreviewGamesTwoImageCell {
        let players = game.players?.allObjects as? [Player]
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.firstIV.image = playersImages[0]
        cell.secondIV.image = playersImages[1]
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        return cell
    }
    
    private func loadThreeImagesCell(cell: PreviewGamesThreeImageCell, playersImages:[UIImage], game:Game, indexPath: IndexPath) -> PreviewGamesThreeImageCell {
        let players = game.players?.allObjects as? [Player]
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        cell.firstIV.image = playersImages[0]
        cell.secondIV.image = playersImages[1]
        cell.thirdIV.image = playersImages[2]
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        return cell
    }
    
    private func loadFourImagesCell(cell: PreviewGamesFourImageCell, playersImages:[UIImage], game:Game, indexPath: IndexPath) -> PreviewGamesFourImageCell {
        let players = game.players?.allObjects as? [Player]
        
        let cell = CellAnimator.add(cell: cell)
        cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 5)
        cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 5)
        cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 5)
        cell.fourthIV = CircleImageCutter.roundImageView(imageview: cell.fourthIV, radius: 5)
        cell.firstIV.image = playersImages[0]
        cell.secondIV.image = playersImages[1]
        cell.thirdIV.image = playersImages[2]
        cell.fourthIV.image = playersImages[3]
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        cell.nameLabel.layer.masksToBounds = true
        cell.nameLabel.layer.cornerRadius = 10
        
        if(gamesStorageLocation[game.gameId!]! == "coreData"){
            cell.downloadBtn.isHidden = true
        }
        else{
            cell.downloadBtn.isHidden = false
            cell.downloadBtn.tag = indexPath.row
            
            cell.downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let game = sections[indexPath.section].games[indexPath.row]
        let playersImages = playerImagesInGameDic[game.gameId!]!
        
        if playersImages == nil {
            return
        }
        
        if var cell = cell as? PreviewGamesTwoImageCell {
            cell = loadTwoImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
        }
        else if var cell = cell as? PreviewGamesThreeImageCell {
            cell = loadThreeImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
        }
        else if var cell = cell as? PreviewGamesFourImageCell {
            cell = loadFourImagesCell(cell: cell, playersImages: playersImages, game: game, indexPath: indexPath)
        }
    }
    
    
    func downloadBtnPressed(sender: UIButton){
        //...
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section].games.count == 0 {
            return ""
        }
        return sections[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameForSegue = sections[indexPath.section].games[indexPath.row]
        performSegue(withIdentifier: "PreviewInGameViewControllerSegue", sender: self)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(!Reachability.isConnectedToNetwork()){
                DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You can't delete games unless there is wifi! Sorry!")
                return
            }
            
            let game = sections[indexPath.section].games[indexPath.row]
            GameStack.sharedInstance.stack.context.delete(game)
            sections[indexPath.section].games.remove(at: indexPath.row)
            
            if gameModels[game.gameId!] == nil {
                self.tableview.reloadData()
                return
            }
            MememeDynamoDB.removeItem(gameModels[game.gameId!]!, completionHandler: { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PreviewInGameViewController{
            destination.game = gameForSegue
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
