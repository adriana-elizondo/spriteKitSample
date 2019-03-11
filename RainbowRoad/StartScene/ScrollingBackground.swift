//
//  ScrollingBackground.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/8.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import SpriteKit

class ScrollingBackground: SKSpriteNode{
    var scrollingSpeed : CGFloat = 0
    
    static func scrollingNodeWithImage(imageName: String, width: CGFloat) -> ScrollingBackground?{
        let image = UIImage(named: imageName)
        guard image != nil else {return nil}
        let node = ScrollingBackground(color: UIColor.clear, size: CGSize(width: width, height: image!.size.height))
        node.scrollingSpeed = 1
        var totalWidthNeeded : CGFloat = 0
        
        while totalWidthNeeded < (width + image!.size.width){
            let child = SKSpriteNode(imageNamed: imageName)
            child.anchorPoint = CGPoint.zero
            child.position = CGPoint(x: totalWidthNeeded, y: 0)
            node.addChild(child)
            totalWidthNeeded += child.size.width
        }
        
        return node
    }
    
    func update(with currentTime: TimeInterval){
        for child in children{
            child.position = CGPoint(x: child.position.x - scrollingSpeed, y: child.position.y)
            
            if child.position.x <= -child.frame.size.width{
                let delta = child.position.x + child.frame.size.width
                child.position = CGPoint(x: (child.frame.size.width * CGFloat(children.count - 1)) + delta, y: child.position.y)
            }
        }
    }
}
