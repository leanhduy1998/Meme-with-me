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
    
    var currentRound = 0
    
    
    
    @IBAction func doneBtnPressed(_ sender: Any) {
    }
    @IBAction func previousBtnPressed(_ sender: Any) {
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFloorBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDimensions()
        reloadPreviewCards()
    }
    func setupDimensions(){
        screenWidth = view.frame.size.width
        // for some reason, the ratio of navigation bar has to be 6/5 for it to not be shorten
    //    screenHeight = view.frame.size.height - navigationBar.frame.height*6/5
        
        space = screenWidth/24
        
        // 44 is the size of two navigation bars
        cardHeight = previewScrollView.frame.height - space - 44*2
        cardWidth = cardHeight*9/16
        
        cardInitialYBeforeAnimation = cardHeight/2
    }
    
    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        var contentWidth = 0 + space
        
        let round = GetGameCoreDataData.getRound(game: game, roundNum: currentRound)
        
        if(round == nil){
            return
        }
        
        var currentPlayersCards = round.cardnormal?.allObjects as? [CardNormal]
        
        let image = UIImage(data: round.cardceasar?.cardPic! as! Data)
        
        
        
            
    
        for x in 0...(((currentPlayersCards?.count)! - 1)) {
            let memeImageView = getMemeIV(image: image!)
            memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
            
            contentWidth += space + cardWidth
            let newX = getNewXForPreviewScroll(x: x)
                
            let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
            let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
                
            // -40 is for animation
            let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
            cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards?[x].playerId)!, memeIV: memeImageView)
            
                
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

}
