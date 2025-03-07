//
//  GameState.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/7/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import AVFoundation

class GameState {
    var score: Int
    var highScore: Int
    var stars: Int
    var currentLevel: Int
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    var loseSceneMusicPlayer: AVAudioPlayer = AVAudioPlayer()

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

        let defaults = UserDefaults.standard

        do {
            if let bgMusicUrl = Bundle.main.url(forResource: "song", withExtension: "mp3") {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: bgMusicUrl)
            }
            
            if let loseMusicUrl = Bundle.main.url(forResource: "castamere", withExtension: "mp3") {
                loseSceneMusicPlayer = try AVAudioPlayer(contentsOf: loseMusicUrl)
            }
        } catch {
            print("Error loading audio files: \(error)")
        }

        highScore = defaults.integer(forKey: "highScore")
        stars = defaults.integer(forKey: "stars")
        currentLevel = 1
        //currentLevel = defaults.integer(forKey: "currentLevel")
    }


    func saveState() {
        highScore = max(score, highScore)

        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(stars, forKey: "stars")
        defaults.set(currentLevel, forKey: "currentLevel")
        UserDefaults.standard.synchronize()
    }

}
