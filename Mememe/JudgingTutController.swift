//
//  JudgingViewController.swift
//  Mememe
//
//  Created by Duy Le on 8/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class JudgingTutController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    
    @IBOutlet weak var memeScrollView: UIScrollView!
    
    var game: Game!
    var playerJudging: String!
    var leaderId: String!
    
    
    var cardHeight: CGFloat!
    var cardWidth: CGFloat!
    
    var space = CGFloat(10)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "UnwindFromJudgeToInGameViewControllerWithSegue", sender: self)
    }
    
    override func viewDidLoad() {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        cardHeight = memeScrollView.frame.height
        cardWidth = cardHeight * 9 / 16
        
        super.viewDidLoad()
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
            memeIV.backgroundColor = UIColor.gray
            
            cardview.initCardView(topLabel: topLabel, bottomLabel: bottomLabel, playerId: card.playerId!, memeIV: memeIV)
            cardview.isSelecting = false
            
            addGestureToCardView(cardView: cardview)
            
            
            
            let chooseIV = UIImageView(frame: CGRect(x: cardWidth/3, y: cardHeight/2 - (cardWidth/3)/2, width: cardWidth/3, height: cardWidth/3))
            chooseIV.image = CircleImageCutter.getRoundEdgeImage(image: #imageLiteral(resourceName: "ichooseyou"), radius: 10)
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
        
        // if no card is selected
        if selectedCard == nil {
            currentCardView?.isSelecting = !(currentCardView?.isSelecting)!
            
            let chooseIV = UIImageView(frame: CGRect(x: cardWidth/3, y: cardHeight/2 - (cardWidth/3)/2, width: cardWidth/3, height: cardWidth/3))
            chooseIV.image = CircleImageCutter.getRoundEdgeImage(image: #imageLiteral(resourceName: "ichooseyou"), radius: 10)
            
            currentCardView?.choosingIV = chooseIV
            currentCardView?.addSubview(chooseIV)
            
            chooseIV.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                chooseIV.alpha = 0.7
                self.memeScrollView.backgroundColor = UIColor.gray
                self.view.backgroundColor = UIColor.gray
                
                for x in 0...(self.memeScrollView.subviews.count-1) {
                    let card = self.memeScrollView.subviews[x] as? ChoosingCardView
                    if card != nil && card?.playerId != currentCardView?.playerId {
                        card?.memeIV.alpha = 0.3
                        card?.bottomLabel.alpha = 0.3
                        card?.topLabel.alpha = 0.3
                        self.memeScrollView.subviews[x].isUserInteractionEnabled = false
                    }
                }
            }, completion: { (completed) in
                if(completed){
                    self.finishBtn.isEnabled = true
                }
            })
        }
        
        // if a card is selected
        if selectedCard != nil {
            finishBtn.isEnabled = false
            
            currentCardView?.isSelecting = !(currentCardView?.isSelecting)!
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                for x in 0...(self.memeScrollView.subviews.count-1) {
                    let card = self.memeScrollView.subviews[x] as? CardView
                    card?.memeIV.alpha = 1
                    card?.bottomLabel.alpha = 1
                    card?.topLabel.alpha = 1
                    self.memeScrollView.subviews[x].isUserInteractionEnabled = true
                }
                self.memeScrollView.backgroundColor = UIColor.white
                self.view.backgroundColor = UIColor.white
                currentCardView?.choosingIV.isHidden = true
            }, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let destination = segue.destination as? InGameTutController {
            destination.step7Finished = true
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
            destination.reloadPreviewCards()
        }
    }
    
    
    
}

