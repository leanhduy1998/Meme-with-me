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
        games = fetchedObjects!
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let numberOfGames = games.count
        return numberOfGames
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = games[indexPath.row]
        
        let players = game.players?.allObjects as? [Player]
        
        var playersImages = [UIImage]()
        
        var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesNoImageCell") as? AvailableGamesNoImageCell)!
        cell = CellAnimator.add(cell: cell)
        
        cell.nameLabel.text = GetGameCoreDataData.getGameAllPlayersAsString(players: players!)
        
        var count = 0
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
                    }
                })
            }
            else{
                image = UIImage(data: player.userImageData as! Data)
            }
            
            var newImage:UIImage;
            let size = CGSize(width: cell.topLeftIV.frame.width, height: cell.topLeftIV.frame.height)
            UIGraphicsBeginImageContextWithOptions(size, true, 0);
            image?.draw(in: CGRect(x:0,y:0,width:size.width, height:size.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext()
            playersImages.append(newImage)
            count = count + 1
        }

       
        let numberOfPlayers = players?.count
        
        switch(numberOfPlayers!){
        case 1:
            cell.topLeftIV.image = playersImages[0]
            break
        case 2:
            cell.topLeftIV.image = playersImages[0]
            cell.topRightIV.image = playersImages[1]
            break
        case 3:
            cell.topLeftIV.image = playersImages[0]
            cell.topRightIV.image = playersImages[1]
            cell.topLeftIV.image = playersImages[2]
            break
        case 4:
            cell.topLeftIV.image = playersImages[0]
            cell.topRightIV.image = playersImages[1]
            cell.topLeftIV.image = playersImages[2]
            cell.topLeftIV.image = playersImages[3]
            break
        default:
            if(numberOfPlayers! > 4){
                cell.topLeftIV.image = playersImages[0]
                cell.topRightIV.image = playersImages[1]
                cell.topLeftIV.image = playersImages[2]
                cell.topLeftIV.image = playersImages[3]
            }
            break
        }
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
