//
//  LevelConfig.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/9/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit
import AVFoundation

class LevelConfig {

    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()

    class func fetchLevel(_ currentLevel: Int) -> [String: Any] {
        if let levelPlist = Bundle.main.path(forResource: "Level\(currentLevel)", ofType: "plist"),
           let levelData = NSDictionary(contentsOfFile: levelPlist) as? [String: Any] {
            return levelData
        }
        return [:]
    }

}

