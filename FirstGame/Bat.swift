//
//  Bat.swift
//  TestGame
//
//  Created by Andrea Masturzo on 03/01/22.
//

import Foundation
import SpriteKit

class Bat: SKSpriteNode, GameSprite {
    var initialSize = CGSize(width: 44, height: 24)
    var textureAtlas: SKTextureAtlas =
    SKTextureAtlas(named: "Enemies")
    var flyAnimation = SKAction()
    init() {
        super.init(texture: nil, color: .clear,
                   size: initialSize)
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        createAnimations()
        self.run(flyAnimation)
        
        // Assign the physics category
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.damagedPenguin.rawValue
    }
    func createAnimations() {
        let flyFrames: [SKTexture] = [
            textureAtlas.textureNamed("bat"),
            textureAtlas.textureNamed("bat-fly")
        ]
        let flyAction = SKAction.animate(with: flyFrames,
                                         timePerFrame: 0.12)
        flyAnimation = SKAction.repeatForever(flyAction)
    }
    func onTap() {}
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
