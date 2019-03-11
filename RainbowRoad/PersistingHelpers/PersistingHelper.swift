//
//  PersistingHelper.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/11.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import UIKit

class PersistingHelper{
    private static let highScoreKey = "HIGH_SCORE"
    
    static func persistCurrentScore(with score: Int){
        let currentHighestScore = UserDefaults.standard.integer(forKey: highScoreKey)
        if score > currentHighestScore{
            UserDefaults.standard.setValue(score, forKey: highScoreKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func highestScore() -> Int{
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }
}
