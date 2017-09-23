//
//  JudgingViewController.swift
//  Mememe
//
//  Created by Duy Le on 8/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class JudgingViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var finishBtn: UIBarButtonItem!
    
    @IBOutlet weak var memeScrollView: UIScrollView!
    
    var game: Game!
    var playerJudging: String!
    var memeImage: UIImage!
    var leaderId: String!
    
    
    var cardHeight: CGFloat!
    var cardWidth: CGFloat!
    
    var space = CGFloat(10)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "UnwindFromJudgeToInGameViewControllerWithSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        var contentWidth = CGFloat(space)
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        var counter = 0
        for card in (latestRound.cardnormal?.allObjects as? [CardNormal])!{
            let cardview = ChoosingCardView(frame: CGRect(x: CGFloat(counter+1)*space + CGFloat(counter)*cardWidth, y: 0, width: cardWidth, height: cardHeight))
            
            let topLabel = UILabel(frame: CGRect(x: space, y: space, width: cardWidth - space*2, height: cardHeight/8))
            MemeLabelConfigurer.configureMemeLabel(topLabel, defaultText: card.topText!)
            
            let bottomLabel = UILabel(frame: CGRect(x: space, y: cardHeight - cardHeight/8 - space, width: cardWidth - space*2, height: cardHeight/8))
            MemeLabelConfigurer.configureMemeLabel(bottomLabel, defaultText: card.bottomText!)
            
            let memeIV = UIImageView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
            memeIV.image = memeImage
            
            cardview.initCardView(topLabel: topLabel, bottomLabel: bottomLabel, playerId: card.playerId!, memeIV: memeIV)
            cardview.isSelecting = false
            
            addGestureToCardView(cardView: cardview)
            
        
            
            let chooseIV = UIImageView(frame: CGRect(x: cardWidth/3, y: cardHeight/2 - (cardWidth/3)/2, width: cardWidth/3, height: cardWidth/3))
            chooseIV.image = CircleImageCutter.getCircleImage(image: #imageLiteral(resourceName: "ichooseyou"), radius: 10)
            chooseIV.alpha = 0
            cardview.addSubview(chooseIV)
            cardview.choosingIV = chooseIV
            
            
            
            memeScrollView.addSubview(cardview)
            
            contentWidth = contentWidth + space + cardWidth
            counter = counter + 1
        }
        
        memeScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        finishBtn.isEnabled = false
    }
    
    func addGestureToCardView(cardView: CardView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.choosingWinnerTap(sender:)))
        
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        
        cardView.addGestureRecognizer(tap)
        
    }
    
    
    func choosingWinnerTap(sender: UITapGestureRecognizer) {
        
        let currentCardView = sender.view as? ChoosingCardView
        var selectedCard: ChoosingCardView!
        
        for x in 0...(memeScrollView.subviews.count-1) {
            let card = memeScrollView.subviews[x] as? ChoosingCardView
            if card?.isSelecting == true {
                selectedCard = card
            }
        }
        
        if selectedCard == nil {
            currentCardView?.isSelecting = !(currentCardView?.isSelecting)!
            for x in 0...(memeScrollView.subviews.count-1) {
                let card = memeScrollView.subviews[x] as? ChoosingCardView
                if card != nil && card?.playerId != currentCardView?.playerId {
                    card?.memeIV.alpha = 0.3
                    card?.bottomLabel.alpha = 0.3
                    card?.topLabel.alpha = 0.3
                }
            }
            let chooseIV = UIImageView(frame: CGRect(x: cardWidth/3, y: cardHeight/2 - (cardWidth/3)/2, width: cardWidth/3, height: cardWidth/3))
            chooseIV.image = CircleImageCutter.getCircleImage(image: #imageLiteral(resourceName: "ichooseyou"), radius: 10)
            
            chooseIV.alpha = 0.7
            
            currentCardView?.choosingIV = chooseIV
            
            currentCardView?.addSubview(chooseIV)
            
            memeScrollView.backgroundColor = UIColor.gray
            view.backgroundColor = UIColor.gray
            
            finishBtn.isEnabled = true
        }
        
        if selectedCard != nil && currentCardView?.playerId == selectedCard.playerId {
            finishBtn.isEnabled = false
            if (currentCardView?.isSelecting)! {
                currentCardView?.isSelecting = !(currentCardView?.isSelecting)!
                
                for x in 0...(memeScrollView.subviews.count-1) {
                    let card = memeScrollView.subviews[x] as? CardView
                    card?.memeIV.alpha = 1
                    card?.bottomLabel.alpha = 1
                    card?.topLabel.alpha = 1
                }
                
                currentCardView?.choosingIV.isHidden = true
                
                memeScrollView.backgroundColor = UIColor.white
                view.backgroundColor = UIColor.white
            }
            else {
                currentCardView?.isSelecting = !(currentCardView?.isSelecting)!
                for x in 0...(memeScrollView.subviews.count-1) {
                    let card = memeScrollView.subviews[x] as? ChoosingCardView
                    if card != nil && card?.playerId != currentCardView?.playerId {
                        card?.memeIV.alpha = 0.3
                        card?.bottomLabel.alpha = 0.3
                        card?.topLabel.alpha = 0.3
                    }
                }
                currentCardView?.choosingIV.isHidden = false
                
                memeScrollView.backgroundColor = UIColor.gray
                view.backgroundColor = UIColor.gray
            }
            
            
        }
        else if selectedCard != nil && currentCardView?.playerId != selectedCard.playerId {
            memeScrollView.backgroundColor = UIColor.gray
            view.backgroundColor = UIColor.gray
            
            for x in 0...(memeScrollView.subviews.count-1) {
                let card = memeScrollView.subviews[x] as? ChoosingCardView
                
                if card?.playerId == currentCardView?.playerId {
                    let chooseIV = UIImageView(frame: CGRect(x: cardWidth/3, y: cardHeight/2 - (cardWidth/3)/2, width: cardWidth/3, height: cardWidth/3))
                    chooseIV.image = CircleImageCutter.getCircleImage(image: #imageLiteral(resourceName: "ichooseyou"), radius: 10)
                    
                    chooseIV.alpha = 0.7
                    
                    card?.choosingIV = chooseIV
                    
                    card?.addSubview(chooseIV)
                    
                    card?.memeIV.alpha = 1
                    card?.bottomLabel.alpha = 1
                    card?.topLabel.alpha = 1
                    
                    card?.isSelecting = true
                }
                else if card != nil {
                    card?.choosingIV.isHidden = true
                    card?.isSelecting = false
                    card?.memeIV.alpha = 0.3
                    card?.bottomLabel.alpha = 0.3
                    card?.topLabel.alpha = 0.3
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is InGameViewController {
            let latestRound = GetGameCoreDataData.getLatestRound(game: game)
            var wonCard = ChoosingCardView()
            for vs in (memeScrollView.subviews as? [ChoosingCardView])! {
                if vs.isSelecting {
                    wonCard = vs
                    break
                }
            }
            for card in (latestRound.cardnormal?.allObjects as? [CardNormal])! {
                if wonCard.playerId == card.playerId {
                    card.didWin = true
                    break
                }
            }
            delegate.saveContext {
                DispatchQueue.main.async {
                    InGameHelper.updateWinnerCard(leaderId: self.leaderId, cardPlayerId: wonCard.playerId)
                }
            }
        }
    }
 


}
