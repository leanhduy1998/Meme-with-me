//
//  GetGameCoreDataData.swift
//  Mememe
//
//  Created by Duy Le on 9/20/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GetGameCoreDataData{
    static func getLatestRound(game: Game) -> Round {
        var latestRound: Round!
        var maxNum = -1
        for round in (game.rounds?.allObjects as? [Round])!{
            if Int(round.roundNum) > maxNum {
                maxNum = Int(round.roundNum)
                latestRound = round
            }
        }
        return latestRound
    }
    static func getRound(game: Game, roundNum: Int) -> Round {
        var round: Round!
        for r in (game.rounds?.allObjects as? [Round])!{
            if Int(r.roundNum) == roundNum {
                round = r
                break
            }
        }
        return round
    }
    static func getRound(game: GameJSONModel, roundNum: Int) -> RoundJSONModel {
        var round: RoundJSONModel!
        for r in game.rounds{
            if r.roundNum == roundNum {
                round = r
                break
            }
        }
        return round
    }
    
    static func getGameAllPlayersAsString(players: [Player])-> String{
        var string = ""
        var count = 0
        for player in players {
            string.append(player.name!)
            if count != players.count - 1 {
                string.append(", ")
            }
            count = count + 1
        }
        return string
    }
    static func getGameAllPlayersAsString(players: [PlayerJSONModel])-> String{
        var string = ""
        var count = 0
        for player in players {
            string.append(player.playerName)
            if count != players.count - 1 {
                string.append(", ")
            }
            count = count + 1
        }
        return string
    }
}
