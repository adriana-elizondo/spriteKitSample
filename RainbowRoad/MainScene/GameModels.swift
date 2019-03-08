//
//  GameModels.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/8.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import GameKit

enum Direction: String{
    case up, down, right
}

enum Enemies: Int{
    case small, medium, large
}

struct Game{
    struct ViewModel {
        struct GameObject{
            var node: SKSpriteNode
            var emmitterNode: SKEmitterNode?
        }
        
        var player: GameObject
        var target: GameObject
        var tracks: [SKSpriteNode]
        var moveSound = SKAction.playSoundFileNamed("move", waitForCompletion: false)
    }
}
