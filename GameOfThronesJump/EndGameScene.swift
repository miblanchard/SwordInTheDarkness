//
//  EndGameScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/9/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)

        backgroundColor = SKColor.blackColor()

        let star = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        addChild(star)

        let lblStars = SKLabelNode(fontNamed: "Luminari")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.redColor()
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        addChild(lblStars)

        let lblScore = SKLabelNode(fontNamed: "Luminari")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.blueColor()
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScore)

        let lblHighScore = SKLabelNode(fontNamed: "Luminari")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.magentaColor()
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 150)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblHighScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)

        let lblTryAgain = SKLabelNode(fontNamed: "Luminari")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)        
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let reveal = SKTransition.fadeWithDuration(0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
}