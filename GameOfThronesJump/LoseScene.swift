//
//  FinishedScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/9/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit
import AVFoundation

class LoseScene: SKScene {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)

        backgroundColor = SKColor.redColor()

        GameState.sharedInstance.loseSceneMusicPlayer.numberOfLoops = -1
        GameState.sharedInstance.loseSceneMusicPlayer.prepareToPlay()
        GameState.sharedInstance.loseSceneMusicPlayer.play()

        let lblLevel = SKLabelNode(fontNamed: "Copperplate")
        lblLevel.fontSize = 30
        lblLevel.fontColor = SKColor.whiteColor()
        lblLevel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        lblLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblLevel.text = String("You fell to your death!")
        addChild(lblLevel)

        let lblHighScore = SKLabelNode(fontNamed: "Copperplate")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.blackColor()
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 150)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblHighScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)

        let lblTryAgain = SKLabelNode(fontNamed: "Copperplate")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        GameState.sharedInstance.loseSceneMusicPlayer.stop()
        GameState.sharedInstance.backgroundMusicPlayer.numberOfLoops = -1
        GameState.sharedInstance.backgroundMusicPlayer.prepareToPlay()
        GameState.sharedInstance.backgroundMusicPlayer.play()
        let reveal = SKTransition.fadeWithDuration(0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
}