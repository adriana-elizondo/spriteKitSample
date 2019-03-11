//
//  GameWorker.swift
//  RainbowRoad
//
//  Created by Adriana Elizondo on 2019/3/8.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import UIKit
import GameKit

protocol GameWorkerProtocol{
    func direction(for track: Int) -> Bool
    func velocity(for index: Int) -> CGFloat
    func generateTrackData(with numberOfTracks: Int)
    func saveScore(score: Int, with completion: @escaping (_ highestScore: Int) -> Void)
}

class GameWorker: GameWorkerProtocol{
    private let trackVelocities = [180, 200, 250]
    private var velocityArray = [CGFloat]()
    private var directionArray = [Bool]()

    
    func direction(for track: Int) -> Bool{
        guard directionArray.count > track else {return false}
        return directionArray[track]
    }
    
    func velocity(for index: Int) -> CGFloat{
        guard velocityArray.count > index else {return 0}
        return velocityArray[index]
    }
    
    func generateTrackData(with numberOfTracks: Int){
        guard numberOfTracks > 0 else { return }
        for _ in 0...numberOfTracks{
            let randomNumberVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
            velocityArray.append(CGFloat(trackVelocities[randomNumberVelocity]))
            directionArray.append(GKRandomSource.sharedRandom().nextBool())
        }
    }
    
    func saveScore(score: Int, with completion: @escaping (_ highestScore: Int) -> Void){
        PersistingHelper.persistCurrentScore(with: score)
        completion(PersistingHelper.highestScore())
    }
}
