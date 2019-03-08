//
//  GamePresenter.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/8.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol GamePresenterLogic{
    func presentPlayer(in position: CGPoint)
    func presentEnemy(enemy: SKShapeNode?, with direction: Direction, and velocity: CGFloat, in track: Int)
    func presentPowerUp(powerup: SKSpriteNode, in track: Int)
    func removeOffScreenEnemies()
}

class GamePresenter: GamePresenterLogic{
    weak var scene: GameDisplayProtocol?
    
    func presentPlayer(in position: CGPoint) {
        let player = SKSpriteNode(imageNamed:"player")
        guard scene != nil else { return }
        player.position = CGPoint(x: position.x, y: scene!.sceneSize.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.collisionBitMask = 0
        player.zPosition = 1
        
        let pulse = SKEmitterNode(fileNamed: "Pulse")
        pulse?.position = CGPoint.zero
        player.addChild(pulse!)
        
        scene?.displayPlayer(with: Game.ViewModel.GameObject(node: player, emmitterNode: pulse))
    }
    
    func presentEnemy(enemy: SKShapeNode?, with direction: Direction, and velocity: CGFloat, in track: Int) {
        guard enemy != nil else {return}
        enemy!.position.y = direction == .up ? -130 : scene!.sceneSize.height + 130
        enemy!.physicsBody = SKPhysicsBody(edgeLoopFrom: enemy!.path!)
        enemy!.physicsBody?.velocity = direction == .up ? CGVector(dx: 0, dy: velocity) :
            CGVector(dx: 0, dy: -velocity)
        scene?.displayEnemy(with: enemy!, in: track)
    }
    
    func presentPowerUp(powerup: SKSpriteNode, in track: Int) {
        scene?.displayPowerUp(with: powerup, in: track)
    }
    
    func removeOffScreenEnemies() {
        if let scene = scene as? SKScene{
            scene.enumerateChildNodes(withName: "Removable") { (node:SKNode, nil) in
                if node.position.y < -150 || node.position.y > scene.size.height + 150 {
                    node.removeFromParent()
                }
            }
        }
    }
}
