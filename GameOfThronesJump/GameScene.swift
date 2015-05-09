//
//  GameScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/2/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    var endLevelY = 0
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var scaleFactor: CGFloat!
    var player: SKNode!
    let tapToStartNode = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/TapToStart")
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0.0
    var maxPlayerY: Int!
    var gameOver = false
//    var currentLevel: Int = 1
//
//    convenience init(size: CGSize, currentLevel: Int) {
//        self.init(size: size)
//        self.currentLevel = currentLevel
//    }

    override init(size: CGSize) {
        super.init(size: size)

        backgroundColor = SKColor.whiteColor()
        scaleFactor = self.size.width / 320.0

        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false

        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self

        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        midgroundNode = createMidgroundNode()
        addChild(midgroundNode)
        foregroundNode = SKNode()
        addChild(foregroundNode)
        hudNode = SKNode()
        addChild(hudNode)

        let currentLevel = GameState.sharedInstance.currentLevel
        setupLevel(currentLevel)

        player = createPlayer()
        foregroundNode.addChild(player)
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180)
        hudNode.addChild(tapToStartNode)

        let star = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        hudNode.addChild(star)

        lblStars = SKLabelNode(fontNamed: "Luminari")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        hudNode.addChild(lblStars)

        lblScore = SKLabelNode(fontNamed: "Luminari")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right

        lblScore.text = "0"
        hudNode.addChild(lblScore)

        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
            (accelerometerData: CMAccelerometerData!, error: NSError!) in
            let acceleration = accelerometerData.acceleration
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        })

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Update elements to show different layers moving at different paces
    override func update(currentTime: NSTimeInterval) {

        if gameOver{
            return
        }

        if Int(player.position.y) > maxPlayerY! {
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY!
            maxPlayerY = Int(player.position.y)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }

        foregroundNode.enumerateChildNodesWithName("NODE_PLATFORM", usingBlock: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(self.player.position.y)
        })

        foregroundNode.enumerateChildNodesWithName("NODE_STAR", usingBlock: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(self.player.position.y)
        })

        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        // Beats the level
        if Int(player.position.y) > endLevelY {
            win()
        }
        // loses level
        if Int(player.position.y) < maxPlayerY - 800 {
            lose()
        }
    }

    override func didSimulatePhysics() {
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
        if player.position.x < -20.0 {
            player.position = CGPoint(x: self.size.width + 20.0, y: player.position.y)
        } else if (player.position.x > self.size.width + 20.0) {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if player.physicsBody!.dynamic {
            return
        }
        tapToStartNode.removeFromParent()
        player.physicsBody?.dynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }

    func didBeginContact(contact: SKPhysicsContact) {
        var updateHUD = false
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        updateHUD = other.collisionWithPlayer(player)
        if updateHUD {
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
    }
    //Create a layer of objects between background image and player/game elements
    func createMidgroundNode() -> SKNode {
        let theMidgroundNode = SKNode()
        var anchor: CGPoint!
        var xPosition: CGFloat!

        for index in 0...9 {
            var spriteName: String
            let r = arc4random() % 2
            if r > 0 {
                spriteName = "GameOfThronesJumpGraphics/Assets.atlas/BranchRight"
                anchor = CGPoint(x: 1.0, y: 0.5)
                xPosition = self.size.width
            } else {
                spriteName = "GameOfThronesJumpGraphics/Assets.atlas/BranchLeft"
                anchor = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
            }

            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.anchorPoint = anchor
            branchNode.position = CGPoint(x: xPosition, y: 500.0 * CGFloat(index))
            theMidgroundNode.addChild(branchNode)
        }

        return theMidgroundNode
    }
    //create the background image layer that changes as you move up
    func createBackgroundNode() -> SKNode {
        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor

        for index in 0...19 {
            let node = SKSpriteNode(imageNamed:String(format: "GameOfThronesJumpGraphics/Backgrounds/Background%02d", index + 1))
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
            backgroundNode.addChild(node)
        }
        return backgroundNode
    }

    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)

        let playerSprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Player")
        playerNode.addChild(playerSprite)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerSprite.size.width / 2)
        playerNode.physicsBody?.dynamic = false
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform

        return playerNode
    }

    func createStarAtPosition(position: CGPoint, ofType type: StarType) -> StarNode {
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"

        var starSprite: SKSpriteNode
        if type == .Special {
            starSprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/StarSpecial")
        } else {
            starSprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Star")
        }
        node.addChild(starSprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: starSprite.size.width / 2)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0

        return node
    }

    func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type

        var sprite: SKSpriteNode
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/PlatformBreak")
        } else {
            sprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Platform")
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }

    func lose() {

        gameOver = true

        GameState.sharedInstance.saveState()

        let reveal = SKTransition.fadeWithDuration(0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
    }

    func win() {

        gameOver = true

        GameState.sharedInstance.saveState()
        GameState.sharedInstance.currentLevel += 1

        let reveal = SKTransition.fadeWithDuration(0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
    }
    
//    func endGame() {
//        
//        gameOver = true
//        
//        GameState.sharedInstance.saveState()
//        
//        let reveal = SKTransition.fadeWithDuration(0.5)
//        // TODO: figure out when to set the youWin flag to true
//        //        if (youWin) { GameState.sharedInstance.currentLevel += 1 }
//
//        let endGameScene = EndGameScene(size: self.size)
//        self.view!.presentScene(endGameScene, transition: reveal)
//    }

    func setupLevel(level: Int) {

        let levelData = LevelConfig.fetchLevel(level)
        let endLevelY = levelData["EndY"]!.integerValue

        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]

        for platformPosition in platformPositions {
            let patternX = platformPosition["x"]?.floatValue
            let patternY = platformPosition["y"]?.floatValue
            let pattern = platformPosition["pattern"] as! NSString

            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            for platformPoint in platformPattern {
                let x = platformPoint["x"]?.floatValue
                let y = platformPoint["y"]?.floatValue
                let type = PlatformType(rawValue: platformPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(platformNode)
            }
        }

        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]

        for starPosition in starPositions {
            let patternX = starPosition["x"]?.floatValue
            let patternY = starPosition["y"]?.floatValue
            let pattern = starPosition["pattern"] as! NSString

            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let x = starPoint["x"]?.floatValue
                let y = starPoint["y"]?.floatValue
                let type = StarType(rawValue: starPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(starNode)
            }
        }

    }
}