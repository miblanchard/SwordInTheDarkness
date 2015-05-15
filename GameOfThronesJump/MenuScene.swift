//
//  MenuScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/14/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MenuScene: SKScene {
    var bgImage = SKSpriteNode(imageNamed: "main.jpg")

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.size = size
        addChild(bgImage)

        let lblStart = SKLabelNode(fontNamed: "Copperplate-Light")
        lblStart.fontSize = 60
        lblStart.fontColor = SKColor.whiteColor()
        lblStart.position = CGPoint(x: self.size.width / 2, y: (self.size.height - 50))
        lblStart.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblStart.text = String("Start")
        addChild(lblStart)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let reveal = SKTransition.fadeWithDuration(0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }


}
