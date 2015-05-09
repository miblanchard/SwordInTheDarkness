//
//  LevelConfig.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/9/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit

class LevelConfig {

    class func fetchLevel(currentLevel: Int) -> NSDictionary {

        let levelPlist = NSBundle.self.mainBundle().pathForResource("Level\(currentLevel)", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        return levelData
    }
}

