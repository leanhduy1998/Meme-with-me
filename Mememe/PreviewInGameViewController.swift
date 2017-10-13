//
//  PreviewInGameViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviewInGameViewController: UIViewController {
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var previousRoundBtn: UIBarButtonItem!
    @IBOutlet weak var nextRoundBtn: UIBarButtonItem!
    @IBOutlet weak var floorBackground: UIImageView!
    
    var game:Game!
    // ui
    var screenWidth : CGFloat!
    var space : CGFloat!
    var cardWidth : CGFloat!
    var cardHeight: CGFloat!
    var iconSize: CGFloat!
    
    var cardInitialYBeforeAnimation: CGFloat!
    var borderForUserIconIV = UIImageView()
    
    var currentRound = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFloorBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDimensions()
        reloadPreviewCards()
        checkSwitchingRoundCondition()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func previousBtnPressed(_ sender: Any) {
        currentRound = currentRound - 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        currentRound = currentRound + 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
    }
    
    func checkSwitchingRoundCondition(){
        if(currentRound == 0){
            previousRoundBtn.isEnabled = false
            nextRoundBtn.isEnabled = true
        }
        if(currentRound == ((game.rounds?.count)!-1)){
            previousRoundBtn.isEnabled = true
            nextRoundBtn.isEnabled = false
        }
    }
    
    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        var contentWidth = 0 + space*2
        
        let round = GetGameCoreDataData.getRound(game: game, roundNum: currentRound)
        
        if(round == nil){
            return
        }
        
        var currentPlayersCards = round.cardnormal?.allObjects as? [CardNormal]
        
        if(currentPlayersCards?.count == 0){
            return
        }
        
        let image = UIImage(data: round.cardceasar?.cardPic! as! Data)
        for x in 0...(((currentPlayersCards?.count)! - 1)) {
            let memeImageView = getMemeIV(image: image!)
            memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            
            contentWidth += space*2 + cardWidth
            let newX = getNewXForPreviewScroll(x: x)
                
            let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
            let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
                
            // -40 is for animation
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards?[x].playerId)!, memeIV: memeImageView)
            
            getUserIconView(game: game, frame: memeImageView.frame, playerCard: currentPlayersCards![x], completeHandler: { (iv) in
                DispatchQueue.main.async {
                    cardUIView.addSubview(iv)
                    cardUIView.bringSubview(toFront: iv)
                }
            })
            
                
            let playerLoves = currentPlayersCards?[x].playerlove?.allObjects as? [PlayerLove]
            
            for love in playerLoves!{
                if(love.playerId == MyPlayerData.id){
                    let heartView = getHeartView(frame: memeImageView.frame, playerCard: (currentPlayersCards?[x])!)
                    
                    heartView.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                        heartView.alpha = 1
                        heartView.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                    }, completion: nil)

                    
                    cardUIView.addSubview(heartView)
                    cardUIView.bringSubview(toFront: heartView)
                    break
                }
            }
                
            previewScrollView.addSubview(cardUIView)
            previewScrollView.bringSubview(toFront: cardUIView)
            
            cardUIView.alpha = 0.5
            
            UIView.animate(withDuration: 1, animations: {
                cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                cardUIView.alpha = 1
            })
        }
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
    }
    
    func reloadCurrentPlayersIcon(){
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        // never use currentPlayersScrollView.frame.height, because it uses the height of its storyboard
        iconSize = 44 - space/2
        
        var counter = 0
        for player in (game.players?.allObjects as? [Player])!{            
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            let userIconIV = UIImageView()
            userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
            contentWidth += self.space + self.iconSize
            
            counter = counter + 1
            
            let redDotSize = iconSize/4
            let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
            redDotIV.frame = CGRect(x: iconSize/2 - (redDotSize)/2, y: -5, width: redDotSize, height: redDotSize)
            let whiteLabel = UILabel()
            
            var timesWon: Int!
            for c in (game.wincounter?.allObjects as? [WinCounter])!{
                if(c.playerId == player.playerId){
                    timesWon = Int(c.won)
                    break
                }
            }
            
            whiteLabel.text = "\(timesWon!)"
            whiteLabel.frame = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)
            whiteLabel.textAlignment = .center
            whiteLabel.textColor = UIColor.white
            redDotIV.addSubview(whiteLabel)
            
            userIconIV.addSubview(redDotIV)
            userIconIV.bringSubview(toFront: redDotIV)
            
            
            let image = UIImage(data: player.userImageData as! Data)!
            userIconIV.image = CircleImageCutter.getRoundEdgeImage(image: image, radius: Float(self.iconSize))
            
            self.currentPlayersScrollView.addSubview(userIconIV)
            self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
            
            let currentRound = GetGameCoreDataData.getRound(game: game, roundNum: self.currentRound)
            for card in (currentRound.cardnormal?.allObjects as? [CardNormal])!{
                if(card.didWin){
                    self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                    userIconIV.addSubview(self.borderForUserIconIV)
                    userIconIV.bringSubview(toFront: self.borderForUserIconIV)
                }
            }
            
            currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
        }
        
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
    }


}
