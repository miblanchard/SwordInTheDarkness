//
//  GameScene.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/2/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var scaleFactor : CGFloat!
    var player: SKNode!
    let tapToStartNode = SKSpriteNode(imageNamed: "GameOfThronesJumpGraphics/Assets.atlas/TapToStart")

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self

        scaleFactor = self.size.width / 320.0
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        foregroundNode = SKNode()
        addChild(foregroundNode)
        hudNode = SKNode()
        addChild(hudNode)
        let star = createStarAtPosition(CGPoint(x: 160, y: 220), ofType: .Special)
        foregroundNode.addChild(star)
        player = createPlayer()
        foregroundNode.addChild(player)
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180)
        hudNode.addChild(tapToStartNode)

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

        }
    }

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
    
}