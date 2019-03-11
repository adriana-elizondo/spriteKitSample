//
//  GameViewController.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/6.
//  Copyright © 2019 adriana. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
    var currentScore: Int = 0
    var bestScore: Int = 0
    private var lastScoreLabel:SKLabelNode?
    private var bestScoreLabel:SKLabelNode?
    private var playButton:SKSpriteNode?
    private var backgroundMusic: SKAudioNode!
    
    override func didMove(to view: SKView) {
        lastScoreLabel = self.childNode(withName: "lastScoreLabel") as? SKLabelNode
        lastScoreLabel?.text = "\(currentScore)"
        
        bestScoreLabel = self.childNode(withName: "bestScoreLabel") as? SKLabelNode
        bestScoreLabel?.text = "\(bestScore)"
        
        playButton = self.childNode(withName: "startButton") as? SKSpriteNode
        
        if let musicURL = Bundle.main.url(forResource: "MenuHighscoreMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {
                let transition = SKTransition.fade(withDuration: 1)
                if let gameScene = SKScene(fileNamed: "GameScene"){
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene, transition: transition)
                }
            }
        }
    }
    
}
