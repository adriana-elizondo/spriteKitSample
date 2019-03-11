//
//  GameScene.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/6.
//  Copyright © 2019 adriana. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameDisplayProtocol : class {
    var sceneSize : CGSize {get}
    func displayPlayer(with viewModel: Game.ViewModel.GameObject)
    func displayEnemy(with shape: SKShapeNode, in track: Int)
    func displayPowerUp(with sprite: SKSpriteNode, in track: Int)
    func displayGameOverScene(with currentScore: Int, and highestScore: Int)
}

class GameScene: SKScene, GameDisplayProtocol {
    private var currentTrack = 0
    private var movingToTrack = false
    private var sound = SKAction.playSoundFileNamed("move", waitForCompletion: false)
    private var player: SKSpriteNode?
    private var interactor: GameBusinessLogic?
    private var tracksArray = [SKSpriteNode]()
    
    private let playerCategory: UInt32 = 0x1 << 0
    private let enemyCategory: UInt32 = 0x1 << 1
    private let targetCategory: UInt32 = 0x1 << 2
    private let powerUpCategory: UInt32 = 0x1 << 3
    
    private var router: GameRoutingProtocol?
    
    private var remainingTime = 10{
        didSet{
            timeLabel?.text = "TIME: \(remainingTime)"
        }
    }
    
    private var score = 0 {
        didSet{
            scoreLabel?.text = "SCORE \(score)"
        }
    }
    
    private var timeLabel : SKLabelNode?
    private var scoreLabel : SKLabelNode?
    private var pauseButton: SKSpriteNode?
    
    var sceneSize: CGSize{
        return size
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setup()
        generateSceneUI()
    }
    
    //Set up
    func setup(){
        let scene = self
        let presenter = GamePresenter()
        presenter.scene = scene
        let interactor = GameInteractor()
        interactor.presenter = presenter
        self.interactor = interactor
        
        let gameRouter = GameRouter()
        gameRouter.view = view
        self.router = gameRouter
        
        if let musicUrl = Bundle.main.url(forResource: "background", withExtension: "wav"){
            let soundNode = SKAudioNode(url: musicUrl)
            addChild(soundNode)
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(self.interactor!.spawnEnemies),
                                                      SKAction.wait(forDuration: 2.0)])))
    }
    
    private func generateSceneUI(){
        generateTracks()
        displayTarget()
        guard let playerPosition = tracksArray.first?.position else {return}
        pauseButton = childNode(withName: "pause") as? SKSpriteNode
        interactor?.configureGame(with: playerPosition, with: tracksArray.count)
        setupTimer()
    }
    
    private func displayTarget() {
        if let node = childNode(withName: "target") as? SKSpriteNode{
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.categoryBitMask = targetCategory
            node.physicsBody?.collisionBitMask = 0
        }
    }
    
    private func generateTracks() {
        for i in 0...7{
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode{
                tracksArray.append(track)
            }
        }
    }
    
    private func setupTimer(){
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.remainingTime -= 1
            }, SKAction.wait(forDuration: 1)]))
        
        timeLabel = childNode(withName: "time") as? SKLabelNode
        timeLabel?.run(timeAction)
        scoreLabel = childNode(withName: "score") as? SKLabelNode
        scoreLabel?.zPosition = 2
    }
    
    
    //Protocol methods
    func displayPlayer(with viewModel: Game.ViewModel.GameObject) {
        player = viewModel.node
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory | powerUpCategory
        addChild(player!)
    }
    
    func displayEnemy(with shape: SKShapeNode, in track: Int) {
        shape.physicsBody?.categoryBitMask = enemyCategory
        guard tracksArray.count > track else {return}
        
        let trackPosition = tracksArray[track].position
        shape.position.x = trackPosition.x
        addChild(shape)
    }
    
    func displayPowerUp(with sprite: SKSpriteNode, in track: Int) {
        sprite.physicsBody?.categoryBitMask = powerUpCategory
        guard tracksArray.count > track else {return}
        
        let trackPosition = tracksArray[track].position
        sprite.position.x = trackPosition.x
        addChild(sprite)
    }
    
    func displayGameOverScene(with currentScore: Int, and highestScore: Int) {
        router?.routeToGameOverScene(with: currentScore, and: highestScore)
    }
    
    //Actions
    private func moveToNextTrack(){
        guard player != nil && currentTrack < 7 else {return}
        
        player!.removeAllActions()
        movingToTrack = true
        guard currentTrack + 1 < interactor?.numberOfTracks ?? 0 else {return}
        let nextTrack = tracksArray[currentTrack + 1]
        let moveAction =  SKAction.move(to: CGPoint(x:nextTrack.position.x, y: player!.position.y), duration: 0.2)
        
        player!.run(moveAction) {
           self.player?.physicsBody?.velocity = self.interactor!.velocityForPlayer(in: self.currentTrack)
            self.movingToTrack = false
            self.currentTrack += 1
        }
        
        self.run(sound)
    }
    
    private func moveVertically(up: Bool){
        if up{
            let moveAction = SKAction.moveBy(x: 0, y: 5, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }else{
            let moveAction = SKAction.moveBy(x: 0, y: -5, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    private func moveToStart(){
        guard player != nil else {return}
        player?.removeFromParent()
        player = nil
        currentTrack = 0
        interactor?.configurePlayer(in: tracksArray.first?.position)
    }
    
    private func getPowerUp(with powerup: SKNode?){
        self.run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: true))
        powerup?.removeFromParent()
        remainingTime -= 5
    }
    
    private func moveToNextLevel(){
        self.run(SKAction.playSoundFileNamed("levelUp.wav", waitForCompletion: true))

        score += 1
        if let emmiterNode = SKEmitterNode(fileNamed: "fireworks.sks"){
            player?.physicsBody?.node?.addChild(emmiterNode)
            
            run(SKAction.wait(forDuration: 0.5)) {
                emmiterNode.removeFromParent()
                self.moveToStart()
            }
        }
    }
    
    private func goToGameOver(){
        self.run(SKAction.playSoundFileNamed("levelCompleted.wav", waitForCompletion: true))
        interactor?.saveScore(with: score)
    }
    
    //overides
    private func getNodeForTouch(touch: UITouch?) -> SKNode?{
        let location = touch?.previousLocation(in: self)
        return nodes(at: location ?? CGPoint.zero).first
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = getNodeForTouch(touch: touches.first) {
            if node.name == "pause"{
                guard view != nil else {return}
                view!.isPaused = !view!.isPaused
                return
            }
            
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
        guard player != nil else {return}
        
        //if player goes offscreen return him to the beginning
        if player!.position.y > size.height || player!.position.y < 0{
            moveToStart()
        }
        
        timeLabel?.fontColor = remainingTime <= 5 ? UIColor.red : UIColor.white
        guard remainingTime <= 0 else {return}
        
        goToGameOver()
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
            self.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: true))
            moveToStart()
        }else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory{
            moveToNextLevel()
        }else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == powerUpCategory{
            getPowerUp(with: otherBody.node)
        }
    }
}
