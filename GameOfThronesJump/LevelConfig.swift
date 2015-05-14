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

    class func fetchLevel(currentLevel: Int) -> NSDictionary {

        let levelPlist = NSBundle.self.mainBundle().pathForResource("Level\(currentLevel)", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        return levelData
        
    }

    class func playThemeMusic() {

        var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()

        var bgMusicUrl:NSURL = NSBundle.mainBundle().URLForResource("song", withExtension: "mp3")!
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicUrl, error: nil)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.play()
    }

}

