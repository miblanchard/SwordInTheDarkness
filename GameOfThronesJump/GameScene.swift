//
//  GameScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/2/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var viewController: UIViewController?
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
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    var finishedGame = false

    override init(size: CGSize) {
        super.init(size: size)

        backgroundColor = SKColor.white
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

        lblStars = SKLabelNode(fontNamed: "Copperplate")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = .left

        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        hudNode.addChild(lblStars)

        lblScore = SKLabelNode(fontNamed: "Copperplate")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = .right

        lblScore.text = "0"
        hudNode.addChild(lblScore)

        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
            guard let accelerometerData = accelerometerData else { return }
            let acceleration = accelerometerData.acceleration
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Update elements to show different layers moving at different paces
    override func update(_ currentTime: TimeInterval) {

        if gameOver{
            return
        }

        if Int(player.position.y) > maxPlayerY! {
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY!
            maxPlayerY = Int(player.position.y)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }

        foregroundNode.enumerateChildNodes(withName: "NODE_PLATFORM") { (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(playerY: self.player.position.y)
        }

        foregroundNode.enumerateChildNodes(withName: "NODE_STAR") { (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(playerY: self.player.position.y)
        }

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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player.physicsBody!.isDynamic {
            return
        }
        tapToStartNode.removeFromParent()
        player.physicsBody?.isDynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var updateHUD = false
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        updateHUD = other.collisionWithPlayer(player: player)
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
        playerNode.physicsBody?.isDynamic = false
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

    func createStarAtPosition(_ position: CGPoint, ofType type: StarType) -> StarNode {
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"

        var starSprite: SKSpriteNode
        if type == StarType.Special {
            starSprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/StarSpecial")
        } else {
            starSprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Star")
        }
        node.addChild(starSprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: starSprite.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0

        return node
    }

    func createPlatformAtPosition(_ position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type

        var sprite: SKSpriteNode
        if type == PlatformType.Break {
            sprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/PlatformBreak")
        } else {
            sprite = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/Platform")
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0

        return node
    }

    func lose() {

        gameOver = true

        GameState.sharedInstance.saveState()
        GameState.sharedInstance.backgroundMusicPlayer.stop()

        let reveal = SKTransition.fade(withDuration: 0.5)
        let loseScene = LoseScene(size: self.size)
        self.view!.presentScene(loseScene, transition: reveal)
    }

    func win() {

        gameOver = true

        GameState.sharedInstance.saveState()
       // backgroundMusicPlayer.stop()


        if GameState.sharedInstance.currentLevel >= 3 {

            finishedGame = true
            let reveal = SKTransition.fade(withDuration: 0.5)
            let finishedGameScene = FinishedGameScene(size: self.size)
            self.view!.presentScene(finishedGameScene, transition: reveal)

        } else {

            GameState.sharedInstance.currentLevel += 1
            let reveal = SKTransition.fade(withDuration: 0.5)
            let endGameScene = EndGameScene(size: self.size)
            self.view!.presentScene(endGameScene, transition: reveal)

        }
    }

    func makeSnowParticles() {
        if let myParticlePath = Bundle.main.path(forResource: "Snow", ofType: "sks") {
            if let snowParticles = try? NSKeyedUnarchiver.unarchivedObject(ofClass: SKEmitterNode.self, from: Data(contentsOf: URL(fileURLWithPath: myParticlePath))) {
                snowParticles.position = CGPoint(x: self.size.width / 2, y: self.size.height)
                addChild(snowParticles)
            }
        }
    }

    func setupLevel(_ level: Int) {

        makeSnowParticles()

        let levelData = LevelConfig.fetchLevel(level)
        endLevelY = levelData["EndY"] as? Int ?? 0

        guard let platforms = levelData["Platforms"] as? [String: Any],
              let platformPatterns = platforms["Patterns"] as? [String: Any],
              let platformPositions = platforms["Positions"] as? [[String: Any]] else {
            return
        }

        for platformPosition in platformPositions {
            let patternX = (platformPosition["x"] as? NSNumber)?.floatValue ?? 0
            let patternY = (platformPosition["y"] as? NSNumber)?.floatValue ?? 0
            guard let pattern = platformPosition["pattern"] as? String else { continue }

            guard let platformPattern = platformPatterns[pattern] as? [[String: Any]] else { continue }
            for platformPoint in platformPattern {
                let x = (platformPoint["x"] as? NSNumber)?.floatValue ?? 0
                let y = (platformPoint["y"] as? NSNumber)?.floatValue ?? 0
                guard let typeValue = (platformPoint["type"] as? NSNumber)?.intValue,
                      let type = PlatformType(rawValue: typeValue) else { continue }
                let positionX = CGFloat(x + patternX)
                let positionY = CGFloat(y + patternY)
                let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type)
                foregroundNode.addChild(platformNode)
            }
        }

        guard let stars = levelData["Stars"] as? [String: Any],
              let starPatterns = stars["Patterns"] as? [String: Any],
              let starPositions = stars["Positions"] as? [[String: Any]] else {
            return
        }

        for starPosition in starPositions {
            let patternX = (starPosition["x"] as? NSNumber)?.floatValue ?? 0
            let patternY = (starPosition["y"] as? NSNumber)?.floatValue ?? 0
            guard let pattern = starPosition["pattern"] as? String else { continue }

            guard let starPattern = starPatterns[pattern] as? [[String: Any]] else { continue }
            for starPoint in starPattern {
                let x = (starPoint["x"] as? NSNumber)?.floatValue ?? 0
                let y = (starPoint["y"] as? NSNumber)?.floatValue ?? 0
                guard let typeValue = (starPoint["type"] as? NSNumber)?.intValue,
                      let type = StarType(rawValue: typeValue) else { continue }
                let positionX = CGFloat(x + patternX)
                let positionY = CGFloat(y + patternY)
                let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType: type)
                foregroundNode.addChild(starNode)
            }
        }
    }
}
