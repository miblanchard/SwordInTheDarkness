//
//  FinishedGameScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/13/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class FinishedGameScene: SKScene {
   // var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    var viewController: UIViewController?
   // let node = SKSpriteNode(imageNamed:String(format: "GameOfThronesJumpGraphics/Backgrounds/Background"))

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func didMoveToView(view: SKView) {
//        var bgMusicUrl:NSURL = NSBundle.mainBundle().URLForResource("song", withExtension: "mp3")!
//        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicUrl, error: nil)
//        backgroundMusicPlayer.numberOfLoops = -1
//        backgroundMusicPlayer.play()
//    }

    override init(size: CGSize) {
        super.init(size: size)

        backgroundColor = SKColor.black

       // node.position = CGPointMake(self.size.width/2, self.size.height/2)
       // node.size = size

        //addChild(node)

        let lblSuccess = SKLabelNode(fontNamed: "Copperplate")
        lblSuccess.fontSize = 30
        lblSuccess.fontColor = SKColor.gray
        lblSuccess.position = CGPoint(x: self.size.width / 2, y: 500)
        lblSuccess.horizontalAlignmentMode = .center
        lblSuccess.text = String("The Night is Dark")
        addChild(lblSuccess)

        let lblLine2 = SKLabelNode(fontNamed: "Copperplate")
        lblLine2.fontSize = 30
        lblLine2.fontColor = SKColor.gray
        lblLine2.position = CGPoint(x: self.size.width / 2, y: 400)
        lblLine2.horizontalAlignmentMode = .center
        lblLine2.text = String("And Full of Terrors")
        addChild(lblLine2)

        let lblRestart = SKLabelNode(fontNamed: "Copperplate")
        lblRestart.fontSize = 30
        lblRestart.fontColor = SKColor.gray
        lblRestart.position = CGPoint(x: self.size.width / 2, y: 150)
        lblRestart.horizontalAlignmentMode = .center
        lblRestart.text = String("Tap to Restart Game")
        addChild(lblRestart)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      //  backgroundMusicPlayer.stop()

        GameState.sharedInstance.currentLevel = 1
        let reveal = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: self.size)
        self.view!.presentScene(menuScene, transition: reveal)
      //  self.viewController!.performSegueWithIdentifier("menu", sender: self)
       // self.viewController!.dismissViewControllerAnimated(true,completion: nil)
    }
}

