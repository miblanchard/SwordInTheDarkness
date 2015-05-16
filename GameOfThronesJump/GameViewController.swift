//
//  GameViewController.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/2/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

   // var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    var backgroundMusicIsPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()

//        var bgMusicUrl:NSURL = NSBundle.mainBundle().URLForResource("song", withExtension: "mp3")!
//        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicUrl, error: nil)
        GameState.sharedInstance.backgroundMusicPlayer.numberOfLoops = -1
        GameState.sharedInstance.backgroundMusicPlayer.prepareToPlay()
        GameState.sharedInstance.backgroundMusicPlayer.play()

        let skView = self.view as! SKView

        skView.showsFPS = false
        skView.showsNodeCount = false

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        
        skView.presentScene(scene)

    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
