//
//  GameRouter.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/11.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameRoutingProtocol{
    func routeToGameOverScene(with myScore: Int, and highest: Int)
}

class GameRouter: GameRoutingProtocol{
    weak var view: SKView?
    
    func routeToGameOverScene(with myScore: Int, and highest: Int) {
        let transition = SKTransition.fade(withDuration: 1)
        if let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene{
            scene.scaleMode = .aspectFill
            scene.currentScore = myScore
            scene.bestScore = highest
            view?.presentScene(scene, transition: transition)
        }
    }
}
