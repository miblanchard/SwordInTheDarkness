//
//  GameObjectNode.swift
//  GameOfThronesJump
//
//  Created by Michael Blanchard on 5/5/15.
//  Copyright (c) 2015 Michael Blanchard. All rights reserved.
//

import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
    static let Enemy: UInt32 = 0x03
}

enum StarType: Int {
    case normal = 0
    case special
}

enum PlatformType: Int {
    case normal = 0
    case break
}

class GameObjectNode: SKNode {

    func collisionWithPlayer(_ player: SKNode) -> Bool {
        return false
    }

    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }
}

class StarNode: GameObjectNode {
    var starType: StarType?
    let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)

    override func collisionWithPlayer(_ player: SKNode) -> Bool {

        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)

        run(starSound, completion: {
            self.removeFromParent()
        })

        GameState.sharedInstance.score += (starType == .normal ? 20 : 100)

        GameState.sharedInstance.stars += (starType == .normal ? 1 : 5)

        return true
    }
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!

    override func collisionWithPlayer(_ player: SKNode) -> Bool {
        if player.physicsBody?.velocity.dy < 0 {
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 350.0)

            if platformType == .break {
                self.removeFromParent()
            }
        }
        
        return false
    }
} 