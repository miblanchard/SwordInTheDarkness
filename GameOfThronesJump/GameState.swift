//
//  GameState.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/7/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import Foundation

class GameState {
    var score: Int
    var highScore: Int
    var stars: Int
    var currentLevel: Int

    class var sharedInstance: GameState {
        struct Singleton {
            static let instance = GameState()
        }

        return Singleton.instance
    }

    init() {
        score = 0
        highScore = 0
        stars = 0
        //currentLevel = 1

        let defaults = NSUserDefaults.standardUserDefaults()

        highScore = defaults.integerForKey("highScore")
        stars = defaults.integerForKey("stars")
        currentLevel = 3
        //currentLevel = defaults.integerForKey("currentLevel")
    }


    func saveState() {
        highScore = max(score, highScore)

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(highScore, forKey: "highScore")
        defaults.setInteger(stars, forKey: "stars")
        defaults.setInteger(currentLevel, forKey: "currentLevel")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
