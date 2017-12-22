//
//  AddEditYourMemeViewController.swift
//  Meme with Me
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import SwiftTryCatch

class AddEditMyMemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var backgroundIV: UIImageView!
    var backgroundImage: UIImage!
    
    @IBOutlet weak var optionBtn: UIBarButtonItem!
    
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    
    var topUIView : UIView!
    var bottomUIView : UIView!
    var dragLabel : UILabel!
    
    var myPlayerId: String!
    var memeImage: UIImage!
    var game: Game!
    
    var leaderId:String!
    
    var imageviewHeight : CGFloat!
    
    var originalFont: UIFont!
    
    var memeModel: MemeModel!
    var memesArrangement = [String]()
    var memesRelatedPos = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        originalFont = UIFont(name: topLabel.font.fontName, size: topLabel.font.pointSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundIV.image = backgroundImage
        
    }
    
    func topUIViewTouched(sender: UITapGestureRecognizer){
        if !isTextEmpty(string: topLabel.text!){
            memesArrangement.append(topLabel.text!)
            self.tableview.reloadData()
            topLabel.text = " "
            topLabel.font = originalFont
        }
    }
    func bottomUIViewTouched(sender: UITapGestureRecognizer){
        if !isTextEmpty(string: bottomLabel.text!){
            memesArrangement.append(bottomLabel.text!)
            self.tableview.reloadData()
            bottomLabel.text = " "
            bottomLabel.font = originalFont
        }
    }
    
    func isTextEmpty(string: String)->Bool{
        if (string == " " || string == "" || string.isEmpty) {
            return true
        }
        return false
    }
    

    @IBAction func finishBtnPressed(_ sender: Any) {
        var topEmpty = false
        if(topLabel.text == nil || topLabel.text == "" || topLabel.text == " "){
            topEmpty = true
        }
        var bottomEmpty = false
        if(bottomLabel.text == nil || bottomLabel.text == "" || bottomLabel.text == " "){
            bottomEmpty = true
        }
        
        if(topEmpty && bottomEmpty){
            DisplayAlert.display(controller: self, title: "Empty memes are boring!", message: "Please fill in your meme!")
            return
        }
        
        if !topEmpty {
            if memesRelatedPos[topLabel.text!] == "top" {
                var count = 0
                for meme in memeModel.topMemes {
                    if meme == topLabel.text! {
                        memeModel.topMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }
            }
            else if memesRelatedPos[topLabel.text!] == "bot" {
                var count = 0
                for meme in memeModel.bottomMemes {
                    if meme == topLabel.text! {
                        memeModel.bottomMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }

            }
            else if memesRelatedPos[topLabel.text!] == "full" {
                var count = 0
                for meme in memeModel.fullMemes {
                    if meme == topLabel.text! {
                        memeModel.fullMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }
            }
        }
        
        if !bottomEmpty {
            if memesRelatedPos[bottomLabel.text!] == "top" {
                var count = 0
                for meme in memeModel.topMemes {
                    if meme == bottomLabel.text! {
                        memeModel.topMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }
            }
            else if memesRelatedPos[bottomLabel.text!] == "bot" {
                var count = 0
                for meme in memeModel.bottomMemes {
                    if meme == bottomLabel.text! {
                        memeModel.bottomMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }
                
            }
            else if memesRelatedPos[bottomLabel.text!] == "full" {
                var count = 0
                for meme in memeModel.fullMemes {
                    if meme == bottomLabel.text! {
                        memeModel.fullMemes.remove(at: count)
                        break
                    }
                    count = count + 1
                }
            }
        }
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        let cardNormals = latestRound.cardnormal?.allObjects as? [CardNormal]
        
        var found = false
        for card in cardNormals! {
            if card.playerId == myPlayerId {
                found = true
                card.topText = topLabel.text!
                card.bottomText = bottomLabel.text!
                
                InGameHelper.insertNormalCardIntoGame(gameId: game.gameId!, card: card)
                break
            }
        }
        
        
        if !found {
            let myCard = CardNormal(bottomText: bottomLabel.text!, didWin: false, playerId: myPlayerId, round: Int((latestRound.roundNum)), topText: topLabel.text!, context: GameStack.sharedInstance.stack.context)
            latestRound.addToCardnormal(myCard)
            
            InGameHelper.insertNormalCardIntoGame(gameId: game.gameId!, card: myCard)
        }
        
        GameStack.sharedInstance.saveContext(completeHandler: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToInGameViewController", sender: self)
            }
        })
    }
    
    func repickOption(action: UIAlertAction) {
        optionBtn.isEnabled = false
        finishBtn.isEnabled = false
        
        topLabel.text = " "
        topLabel.font = originalFont
        
        bottomLabel.text = " "
        bottomLabel.font = originalFont
        
        self.memesArrangement.removeAll()
        self.memesRelatedPos.removeAll()
        
        self.memeModel = MemeHelper.get9Memes()
        self.memesArrangement.append(contentsOf: self.memeModel.topMemes)
        self.memesArrangement.append(contentsOf: self.memeModel.bottomMemes)
        self.memesArrangement.append(contentsOf: self.memeModel.fullMemes)
        self.memesArrangement.shuffle()
        
        for meme in self.memeModel.topMemes {
            self.memesRelatedPos[meme] = "top"
        }
        for meme in self.memeModel.bottomMemes {
            self.memesRelatedPos[meme] = "bot"
        }
        for meme in self.memeModel.fullMemes {
            self.memesRelatedPos[meme] = "full"
        }
        tableview.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.optionBtn.isEnabled = true
            self.finishBtn.isEnabled = true
        }
    }
    
    @IBAction func optionBtnPressed(_ sender: Any) {
        let optionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        optionAlertController.addAction(UIAlertAction(title: "Repick Cards", style: UIAlertActionStyle.default, handler: repickOption))
        optionAlertController.addAction(UIAlertAction(title: "Help", style: UIAlertActionStyle.default, handler: helpOption))
        optionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(optionAlertController, animated: true, completion: nil)
    }
    func helpOption(action: UIAlertAction){
        DisplayAlert.display(controller: self, title: "", message: "Hold the meme line to drag it onto the image. Tap the meme line on the image to delete it!")
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToInGameViewController", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? InGameViewController {
            destination.game = game
            destination.myTopText = topLabel.text!
            destination.myBottomText = bottomLabel.text!
            destination.memesArrangement = memesArrangement
            destination.memesRelatedPos = memesRelatedPos
            destination.memeModel = memeModel
        }
    }
}
