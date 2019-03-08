//
//  GameViewController.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/6.
//  Copyright © 2019 adriana. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = view as? SKView{
            if let scene = SKScene(fileNamed: "GameScene"){
                scene.scaleMode = .aspectFit
                view.showsFPS = true
                view.showsNodeCount = true
                view.presentScene(scene)
                
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
