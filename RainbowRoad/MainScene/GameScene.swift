//
//  GameScene.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/6.
//  Copyright © 2019 adriana. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Direction: String{
    case up, down, right
}

enum Enemies: Int{
    case small, medium, large
}

class GameScene: SKScene {
    var tracksArray = [SKSpriteNode]()
    let trackVelocities = [180, 200, 250]
    var velocityArray = [CGFloat]()
    var directionArray = [Bool]()
    var player: SKSpriteNode?
    var target: SKSpriteNode?
    
    private var currentTrack = 0
    private var movingToTrack = false
    private var sound = SKAction.playSoundFileNamed("move", waitForCompletion: false)
    
    let playerCategory: UInt32 = 0x1 << 0
    let enemyCategory: UInt32 = 0x1 << 1
    let targetCategory: UInt32 = 0x1 << 2
    
    override func didMove(to view: SKView) {
        setupTracks()
        createData()
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemies),
                                                           SKAction.wait(forDuration: 2.0)])))
    }
    
    private func createData(){
        let numberOfTracks = tracksArray.count
        guard numberOfTracks > 0 else { return }
        for _ in 0...numberOfTracks{
            let randomNumberVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
            velocityArray.append(CGFloat(trackVelocities[randomNumberVelocity]))
            directionArray.append(GKRandomSource.sharedRandom().nextBool())
        }
    }
    
    private func createPlayer(){
        player = SKSpriteNode(imageNamed:"player")
        guard let playerPosition = tracksArray.first?.position.x else {return}
        
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        player?.physicsBody?.linearDamping = 0
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory
        
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "Pulse")
        player?.addChild(pulse!)
        pulse?.position = CGPoint.zero
    }
    
    private func createTarget(){
        if let node = childNode(withName: "target") as? SKSpriteNode{
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.categoryBitMask = targetCategory
        }
    }
    
    private func createEnemies(type: Enemies, track: Int) -> SKShapeNode?{
        let enemieSprite = SKShapeNode()
        enemieSprite.name = "Enemy"
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
        
        guard tracksArray.count > track else {return nil}
        
        let trackPosition = tracksArray[track].position
        let up = directionArray[track]
        
        enemieSprite.position.x = trackPosition.x
        enemieSprite.position.y = up ? -130 : size.height + 130
        enemieSprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemieSprite.path!)
        enemieSprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) :
        CGVector(dx: 0, dy: -velocityArray[track])
        enemieSprite.physicsBody?.categoryBitMask = enemyCategory
        
        return enemieSprite
    }
    
    private func spawnEnemies(){
        for i in 1...6{
            let randomEnemieType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))
            if let newEnemie = createEnemies(type: randomEnemieType!, track: i) {
                self.addChild(newEnemie)
            }
        }
        
        self.enumerateChildNodes(withName: "Enemy") { (node:SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    private func setupTracks(){
        for i in 0...7{
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode{
                tracksArray.append(track)
            }
        }
    }
    
    private func moveToNextTrack(){
        guard player != nil else {return}
        
        player!.removeAllActions()
        movingToTrack = true
        guard currentTrack + 1 < tracksArray.count else {return}
        let nextTrack = tracksArray[currentTrack + 1]
        let moveAction =  SKAction.move(to: CGPoint(x:nextTrack.position.x, y: player!.position.y), duration: 0.2)
        player!.run(moveAction) {
            self.movingToTrack = false
        }
        currentTrack += 1
        
        self.run(sound)
    }
    
    //overides
    private func getNodeForTouch(touch: UITouch?) -> SKNode?{
        let location = touch?.previousLocation(in: self)
        return nodes(at: location ?? CGPoint.zero).first
    }
    
    private func moveVertically(up: Bool){
        if up{
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }else{
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = getNodeForTouch(touch: touches.first) {
            let direction = Direction(rawValue: node.name ?? "")
            switch direction{
            case .up?:
                moveVertically(up: true)
            case .down?:
                moveVertically(up: false)
            case .right?:
                moveToNextTrack()
            default:
                print("wtf")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack{
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}

//Contact delegate
extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        }else{
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory{
            print("enemy hit")
        }else if playerBody.categoryBitMask == playerCategory  && otherBody.categoryBitMask == targetCategory{
            print("hit target")
        }
    }
}
