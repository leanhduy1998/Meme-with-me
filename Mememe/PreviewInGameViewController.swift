//
//  PreviewInGameViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviewInGameViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var previousRoundBtn: UIBarButtonItem!
    @IBOutlet weak var nextRoundBtn: UIBarButtonItem!
    @IBOutlet weak var floorBackground: UIImageView!
    
    var game:Any!
    // ui
    var screenWidth : CGFloat!
    var space = CGFloat(5)
    var cardWidth : CGFloat!
    var cardHeight: CGFloat!
    var iconSize: CGFloat!
    
    var cardInitialYBeforeAnimation: CGFloat!
    var borderForUserIconIV = UIImageView()
    
    var currentRound = 0
    
    let helper = UserFilesHelper()
    
    var topTextSegue: String!
    var bottomTextSegue: String!
    var detailPictureSegueSent = false
    var imageSegue: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFloorBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDimensions()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
        checkSwitchingRoundCondition()
        detailPictureSegueSent = false
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func previousBtnPressed(_ sender: Any) {
        currentRound = currentRound - 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        currentRound = currentRound + 1
        checkSwitchingRoundCondition()
        clearPreviewCardsData()
        reloadPreviewCards()
        reloadCurrentPlayersIcon()
    }
    
    func checkSwitchingRoundCondition(){
        if(currentRound == 0){
            previousRoundBtn.isEnabled = false
            nextRoundBtn.isEnabled = true
        }
        if let game = game as? Game {
            if(currentRound == ((game.rounds?.count)!-1)){
                if(currentRound == 0){
                    previousRoundBtn.isEnabled = false
                }
                else{
                    previousRoundBtn.isEnabled = true
                }
                nextRoundBtn.isEnabled = false
            }
            if(currentRound > 0 && currentRound < ((game.rounds?.count)!-1)){
                previousRoundBtn.isEnabled = true
                nextRoundBtn.isEnabled = true
            }
        }
        else if let game = game as? GameJSONModel {
            if(currentRound == ((game.rounds.count)-1)){
                if(currentRound == 0){
                    previousRoundBtn.isEnabled = false
                }
                else{
                    previousRoundBtn.isEnabled = true
                }
                nextRoundBtn.isEnabled = false
            }
            if(currentRound > 0 && currentRound < ((game.rounds.count)-1)){
                previousRoundBtn.isEnabled = true
                nextRoundBtn.isEnabled = true
            }
        }
    }
    
    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        if let game = game as? Game {
            let round = GetGameCoreDataData.getRound(game: game, roundNum: currentRound)
            
            var image = FileManagerHelper.getImageFromMemory(imagePath: (round.cardceasar?.imageStorageLocation)!)
            
            if(image == #imageLiteral(resourceName: "ichooseyou")){
                let helper = UserFilesHelper()
                helper.getMemeData(memeUrl: (round.cardceasar?.cardDBUrl)!, completeHandler: { (memeImageData) in
                    DispatchQueue.main.async {
                        image = UIImage(data: memeImageData)!
                        self.loadPreviewScrollView(image: image, round: round)
                    }
                })
            }
            else{
                loadPreviewScrollView(image: image, round: round)
            }
        }
        else if let game = game as? GameJSONModel {
            let round = GetGameCoreDataData.getRound(game: game, roundNum: currentRound)
            
            var image = FileManagerHelper.getImageFromMemory(imagePath: (round.cardCeasar.imageStorageLocation))
            
            if(image == #imageLiteral(resourceName: "ichooseyou")){
                helper.getMemeData(memeUrl: (round.cardCeasar.cardDBurl)!, completeHandler: { (memeImageData) in
                    DispatchQueue.main.async {
                        image = UIImage(data: memeImageData)!
                        self.loadPreviewScrollView(image: image, round: round)
                    }
                })
            }
            else{
                loadPreviewScrollView(image: image, round: round)
            }
        }
        
    }
    
    func loadPreviewScrollView(image:UIImage,round:Round){
        var contentWidth = 0 + space*2
        
        var currentPlayersCards = round.cardnormal?.allObjects as? [CardNormal]
        
        if(currentPlayersCards?.count == 0){
            contentWidth = contentWidth + cardWidth
            
            let newX = getNewXForPreviewScroll(x: 0)
            let memeImageView = getMemeIV(image: image)
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            
            cardUIView.memeIV = memeImageView
            cardUIView.addSubview(memeImageView)
            cardUIView.bringSubview(toFront: memeImageView)
            
            previewScrollView.addSubview(cardUIView)
            previewScrollView.bringSubview(toFront: cardUIView)
            
            cardUIView.alpha = 0.5
            
            UIView.animate(withDuration: 1, animations: {
                cardUIView.frame = CGRect(x: newX, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                cardUIView.alpha = 1
            })
            previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
            return
        }
        
        for x in 0...(((currentPlayersCards?.count)! - 1)) {
            let memeImageView = getMemeIV(image: image)
            memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            
            contentWidth += space*2 + cardWidth
            
            let newX = getNewXForPreviewScroll(x: x)
            
            let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
            let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
            
            // -40 is for animation
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards?[x].playerId)!, memeIV: memeImageView)
            
            var round: Round!
            
            let game = self.game as? Game
            
            for r in (game?.rounds?.allObjects as? [Round])!{
                if Int(r.roundNum) == currentRound {
                    round = r
                    break
                }
            }
            
            getUserIconView(round: round, frame: memeImageView.frame, playerCard: currentPlayersCards![x], completeHandler: { (iv) in
                DispatchQueue.main.async {
                    cardUIView.addSubview(iv)
                    cardUIView.bringSubview(toFront: iv)
                }
            })
            
       
            if(currentPlayersCards![x].didWin){
                let borderForCard = self.getBorderForWinningCard()
                cardUIView.addSubview(borderForCard)
                cardUIView.bringSubview(toFront: borderForCard)
            }
            
            
            
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
            
            let tap = UILongPressGestureRecognizer(target: self, action: #selector(showPictureDetailTap))
            
            tap.delegate = self
            cardUIView.addGestureRecognizer(tap)
            
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
    
    func loadPreviewScrollView(image:UIImage,round:RoundJSONModel){
        var contentWidth = 0 + space*2
        
        var currentPlayersCards = round.cardNormal
        
        if(currentPlayersCards.count == 0){
            contentWidth = contentWidth + cardWidth
            
            let newX = getNewXForPreviewScroll(x: 0)
            let memeImageView = getMemeIV(image: image)
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            
            cardUIView.memeIV = memeImageView
            cardUIView.addSubview(memeImageView)
            cardUIView.bringSubview(toFront: memeImageView)
            
            previewScrollView.addSubview(cardUIView)
            previewScrollView.bringSubview(toFront: cardUIView)
            
            cardUIView.alpha = 0.5
            
            UIView.animate(withDuration: 1, animations: {
                cardUIView.frame = CGRect(x: newX, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                cardUIView.alpha = 1
            })
            previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
            return
        }
        
        for x in 0...(((currentPlayersCards.count) - 1)) {
            let memeImageView = getMemeIV(image: image)
            memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            
            contentWidth += space*2 + cardWidth
            
            let newX = getNewXForPreviewScroll(x: x)
            
            let upLabel = getTopLabel(text: (currentPlayersCards[x].topText)!)
            let downLabel = getBottomLabel(text: (currentPlayersCards[x].bottomText)!)
            
            // -40 is for animation
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards[x].playerId)!, memeIV: memeImageView)
            
            var round: RoundJSONModel!
            
            let game = self.game as? GameJSONModel
            
            for r in (game?.rounds)!{
                if r.roundNum == currentRound {
                    round = r
                    break
                }
            }
            getUserIconView(round: round, frame: memeImageView.frame, playerCard: currentPlayersCards[x], completeHandler: { (iv) in
                DispatchQueue.main.async {
                    cardUIView.addSubview(iv)
                    cardUIView.bringSubview(toFront: iv)
                }
            })

            
            if(currentPlayersCards[x].didWin){
                let borderForCard = self.getBorderForWinningCard()
                cardUIView.addSubview(borderForCard)
                cardUIView.bringSubview(toFront: borderForCard)
            }
            
            
            
            let playerLoves = currentPlayersCards[x].playerLove
            
            for love in playerLoves{
                if(love.playerId == MyPlayerData.id){
                    let heartView = getHeartView(frame: memeImageView.frame, playerCard: (currentPlayersCards[x]))
                    
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
            
            let tap = UILongPressGestureRecognizer(target: self, action: #selector(showPictureDetailTap))
            
            tap.delegate = self
            cardUIView.addGestureRecognizer(tap)
            
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
    
    func showPictureDetailTap(sender: UILongPressGestureRecognizer) {
        let cardView = sender.view as? CardView
        topTextSegue = cardView?.topText
        bottomTextSegue = cardView?.bottomText
        imageSegue = cardView?.memeIV.image
        
        if !detailPictureSegueSent{
            detailPictureSegueSent = true
            performSegue(withIdentifier: "PreviewShowImageDetailSegue", sender: self)
        }
    }
    
    func reloadCurrentPlayersIcon(){
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        iconSize = 100 - space
        
        var counter = 0
        
        if let game = game as? Game{
            var round: Round!
            
            for r in (game.rounds?.allObjects as? [Round])!{
                if Int(r.roundNum) == currentRound {
                    round = r
                    break
                }
            }
            
            for player in (round.players?.allObjects as? [Player])!{
                let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
                var userIconIV = UIImageView()
                userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
                contentWidth += self.space + self.iconSize
                
                counter = counter + 1
                
                let redDotSize = iconSize/4
                let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
                redDotIV.frame = CGRect(x: iconSize/2 - (redDotSize)/2, y: 0, width: redDotSize, height: redDotSize)
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
                
                let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
                if image == #imageLiteral(resourceName: "ichooseyou") {
                    helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                            userIconIV.image = image
                        }
                    })
                }
                else{
                    userIconIV.image = image
                }
                
                userIconIV = UIImageViewHelper.roundImageView(imageview: userIconIV, radius: 5)
                
                self.currentPlayersScrollView.addSubview(userIconIV)
                self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
                
                for card in (round.cardnormal?.allObjects as? [CardNormal])!{
                    if(card.didWin && card.playerId == player.playerId){
                        self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                        currentPlayersScrollView.addSubview(self.borderForUserIconIV)
                        currentPlayersScrollView.bringSubview(toFront: self.borderForUserIconIV)
                    }
                }
                
                currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
            }
        }
        else if let game = game as? GameJSONModel{
            var round: RoundJSONModel!
            
            for r in game.rounds{
                if r.roundNum == currentRound {
                    round = r
                    break
                }
            }
            
            for player in round.players{
                let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
                var userIconIV = UIImageView()
                userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
                contentWidth += self.space + self.iconSize
                
                counter = counter + 1
                
                let redDotSize = iconSize/4
                let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
                redDotIV.frame = CGRect(x: iconSize/2 - (redDotSize)/2, y: 0, width: redDotSize, height: redDotSize)
                let whiteLabel = UILabel()
                
                var timesWon: Int!
                for c in game.winCounter{
                    if(c.playerId == player.playerId){
                        timesWon = c.wonNum
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
                
                
                let image = FileManagerHelper.getImageFromMemory(imagePath: player.userImageLocation)
                if image == #imageLiteral(resourceName: "ichooseyou") {
                    helper.loadUserProfilePicture(userId: player.playerId, completeHandler: { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                            userIconIV.image = image
                        }
                    })
                }
                else{
                    userIconIV.image = image
                }
                
                userIconIV = UIImageViewHelper.roundImageView(imageview: userIconIV, radius: 5)
                
                self.currentPlayersScrollView.addSubview(userIconIV)
                self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
                
                for card in round.cardNormal{
                    if(card.didWin && card.playerId == player.playerId){
                        self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                        userIconIV.addSubview(self.borderForUserIconIV)
                        userIconIV.bringSubview(toFront: self.borderForUserIconIV)
                    }
                }
                
                currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
            }
        }
        
        
        
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PictureDetailViewController {
            destination.topText = topTextSegue
            destination.bottomText = bottomTextSegue
            destination.image = imageSegue
        }
    }


}
