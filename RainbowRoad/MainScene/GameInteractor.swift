//
//  GameInteractor.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/8.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import UIKit
import GameKit

protocol GameBusinessLogic{
    var numberOfTracks: Int { get }
    func configureGame(with startPosition: CGPoint, with numberOfTracks: Int)
    func configurePlayer(in position: CGPoint?)
    func velocityForPlayer(in track: Int) -> CGVector
    func spawnEnemies()
    func pauseGame()
}

class GameInteractor: GameBusinessLogic{
    var presenter: GamePresenterLogic?
    let worker = GameWorker()
    var numberOfTracks: Int = 0
    
    func configureGame(with startPosition: CGPoint, with numberOfTracks: Int) {
        self.numberOfTracks = numberOfTracks
        worker.generateTrackData(with: numberOfTracks)
        presenter?.presentPlayer(in: startPosition)
        spawnEnemies()
    }
    
    func configurePlayer(in position: CGPoint?){
        presenter?.presentPlayer(in: position ?? CGPoint.zero)
    }
    
    func createPowerUp(in track: Int){
        let powerUp = SKSpriteNode(imageNamed: "powerUp")
        
        powerUp.name = "Removable"
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width / 2)
        powerUp.physicsBody?.linearDamping = 0
        powerUp.physicsBody?.collisionBitMask = 0
        
        let up = worker.direction(for: track + 1)
        powerUp.position.y = up ? 0 : UIScreen.main.bounds.height 
        powerUp.physicsBody?.velocity = velocityForPlayer(in: track)
        
        presenter?.presentPowerUp(powerup: powerUp, in: track)
    }
    
    func spawnEnemies(){
        var randomTrackNumber = 0
        let shouldAddPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if shouldAddPowerUp{
            randomTrackNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 5) + 1
            createPowerUp(in: randomTrackNumber)
        }
        
        for i in 1...6{
            guard i != randomTrackNumber else {continue}
            let randomEnemieType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))
            createEnemies(type: randomEnemieType!, track: i)
        }
        
        presenter?.removeOffScreenEnemies()
    }
    
    func velocityForPlayer(in track: Int) -> CGVector{
        let direction = worker.direction(for: track + 1)
        let velocity = track == numberOfTracks - 2 ? 0 : worker.velocity(for: track)
        return CGVector(dx: 0, dy: direction ? velocity : -velocity)
    }
    
    //
    private func createEnemies(type: Enemies, track: Int){
        let enemieSprite = SKShapeNode()
        enemieSprite.name = "Removable"
        switch type {
        case .small:
            enemieSprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemieSprite.fillColor = UIColor(displayP3Red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1.0)
        case .medium:
            enemieSprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemieSprite.fillColor = UIColor(displayP3Red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1.0)
        case .large:
            enemieSprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemieSprite.fillColor = UIColor(displayP3Red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1.0)
        }
        
        let up = worker.direction(for: track)
        let direction : Direction = up ? .up : .down
        presenter?.presentEnemy(enemy: enemieSprite, with: direction, and: worker.velocity(for: track), in: track)
        
    }
    
    func pauseGame() { }

}
