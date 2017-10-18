//
//  GameTreeSort.swift
//  Mememe
//
//  Created by Duy Le on 10/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GameTreeSort{
  //  private var root = GameTreeNode()
    func sortGames(games: [Game]) -> [Game]{
        for game in games{
            
        }
        return []
    }
    func insertNodeIntoTree(node: GameTreeNode, game:Game,height: Int){
        if(node == nil){
            node.game = game
            node.height = height
        }
        //left
        else if((node.game.createdDate! as Date) > game.createdDate! as Date){
            node.left.root = node
            insertNodeIntoTree(node: node.left, game: game, height: node.height)
          //  node.height = node.height + 1
          //  node.left.game = game
            node.height = 1 + getBalance(node: node)
        }
        //right
        else if((node.game.createdDate! as Date) < game.createdDate! as Date){
            node.right.root = node
            insertNodeIntoTree(node: node.right, game: game, height: node.height)
            node.height = 1 + getBalance(node: node)
        }
    }
    func getBalance(node: GameTreeNode)->Int{
        if(node.left != nil && node.right != nil){
            return max(node.left.height, node.right.height)
        }
        else if(node.left != nil && node.right == nil){
            return node.left.height
        }
        else if(node.left == nil && node.right != nil){
            return node.right.height
        }
        else{
            return -1
        }
    }
    func rotate(node: GameTreeNode){
        if(abs(getBalance(node: node.left) - getBalance(node: node.right))<2){
            return
        }
        else{
            if(getBalance(node: node.left)>getBalance(node: node.right)){
                if(node.game == node.root.right.game){
                    node.root.right = node.left
                    node.root = node.left
                    
                }
            }
        }
    }
}
