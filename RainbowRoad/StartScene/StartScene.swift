//
//  GameViewController.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/6.
//  Copyright © 2019 adriana. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    var playButton:SKSpriteNode?
    var gameScene:SKScene!
    var backgroundMusic: SKAudioNode!
    var scrollingBackground: ScrollingBackground?
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "startButton") as? SKSpriteNode
        
        if let musicURL = Bundle.main.url(forResource: "MenuHighscoreMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
        scrollingBackground = ScrollingBackground.scrollingNodeWithImage(imageName: "loopBG", width: size.width)
        scrollingBackground?.scrollingSpeed = 1.5
        scrollingBackground?.anchorPoint = .zero
        addChild(scrollingBackground!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {
                let transition = SKTransition.fade(withDuration: 1)
                gameScene = SKScene(fileNamed: "GameScene")
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard scrollingBackground != nil else {return}
        scrollingBackground?.update(with: currentTime)
    }
}
