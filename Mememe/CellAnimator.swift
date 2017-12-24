//
//  CellAnimator.swift
//  Mememe
//
//  Created by Duy Le on 9/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class CellAnimator{
    static func add(cell: PlayerCollectionViewCell) -> PlayerCollectionViewCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: NotificationTableViewCell) -> NotificationTableViewCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: UITableViewCell) -> UITableViewCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: AvailableGamesOneImageCell) -> AvailableGamesOneImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: AvailableGamesTwoImageCell) -> AvailableGamesTwoImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: AvailableGamesThreeImageCell) -> AvailableGamesThreeImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: AvailableGamesFourImageCell) -> AvailableGamesFourImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: PreviewGamesTwoImageCell) -> PreviewGamesTwoImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: PreviewGamesThreeImageCell) -> PreviewGamesThreeImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: PreviewGamesFourImageCell) -> PreviewGamesFourImageCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: PrivateRoomTableCell) -> PrivateRoomTableCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: MyChatTableViewCell) -> MyChatTableViewCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
    static func add(cell: HerChatTableViewCell) -> HerChatTableViewCell{
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        },completion: { finished in})
        return cell
    }
}
