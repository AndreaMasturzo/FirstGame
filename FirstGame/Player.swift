//
//  Player.swift
//  TestGame
//
//  Created by Andrea Masturzo on 30/12/21.
//

import Foundation
import SpriteKit
class Player : SKSpriteNode, GameSprite {
    let powerupSound = SKAction.playSoundFileNamed("Sound/Powerup.aif", waitForCompletion: false)
    let hurtSound = SKAction.playSoundFileNamed("Sound/Hurt.aif", waitForCompletion: false)
    var health = 3
    var invulnerable = false
    var damaged = false
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var forwardVelocity: CGFloat = 200
    var initialSize = CGSize(width: 64, height: 64)
    var textureAtlas: SKTextureAtlas =
    SKTextureAtlas(named: "Pierre")
    // Pierre has multiple animations. Right now, we will
    // create one animation for flying up,
    // and one for going down:
    var flyAnimation = SKAction()
    var soarAnimation = SKAction()
    
    // Store whether we are flapping our wings or in free-fall:
    var flapping = false
    // Set a maximum upward force.
    // 57,000 feels good to me, adjust to taste:
    let maxFlappingForce: CGFloat = 57000
    // Pierre should slow down when he flies too high:
    let maxHeight: CGFloat = 1000
    init() {
        // Call the init function on the
        // base class (SKSpriteNode)
        super.init(texture: nil, color: .clear, size:
                    initialSize)
        createAnimations()
        self.run(soarAnimation, withKey: "soarAnimation")
        // Create a physics body based on one frame of Pierre's animation.
        // We will use the third frame, when his wings are tucked in
        let bodyTexture = textureAtlas.textureNamed("pierre-flying-3")
        self.physicsBody = SKPhysicsBody(
            texture: bodyTexture, size: self.size)
        // Pierre will lose momentum quickly with a high linearDamping:
        self.physicsBody?.linearDamping = 0.9
        // Adult penguins weigh around 30kg:
        self.physicsBody?.mass = 30
        // Prevent Pierre from rotating:
        self.physicsBody?.allowsRotation = false
        
        // Assign physics category and set up contact logic
        self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy.rawValue | PhysicsCategory.ground.rawValue | PhysicsCategory.powerup.rawValue | PhysicsCategory.coin.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        
        // Grant a momentary reprieve from gravity
        self.physicsBody?.affectedByGravity = false
        // Add some slight upward velocity
        self.physicsBody?.velocity.dy = 80
        // Create a SKAction to start gravity after a small delay
        let startGravitySequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run {
                self.physicsBody?.affectedByGravity = true
            }
        ])
        
    }
    func createAnimations() {
        let rotateUpAction =
        SKAction.rotate(toAngle: 0, duration: 0.475)
        rotateUpAction.timingMode = .easeOut
        let rotateDownAction = SKAction.rotate(toAngle:
                                                -1, duration: 0.8)
        rotateDownAction.timingMode = .easeIn
        // Create the flying animation:
        let flyFrames: [SKTexture] = [
            textureAtlas.textureNamed("pierre-flying-1"),
            textureAtlas.textureNamed("pierre-flying-2"),
            textureAtlas.textureNamed("pierre-flying-3"),
            textureAtlas.textureNamed("pierre-flying-4"),
            textureAtlas.textureNamed("pierre-flying-3"),
            textureAtlas.textureNamed("pierre-flying-2")
        ]
        let flyAction = SKAction.animate(with: flyFrames,
                                         timePerFrame: 0.03)
        // Group together the flying animation with rotation:
        flyAnimation = SKAction.group([
            SKAction.repeatForever(flyAction),
            rotateUpAction
        ])
        // Create the soaring animation,
        // just one frame for now:
        let soarFrames: [SKTexture] =
        [textureAtlas.textureNamed("pierre-flying-1")]
        let soarAction = SKAction.animate(with:
                                            soarFrames,
                                          timePerFrame: 1)
        // Group the soaring animation with the rotation down:
        soarAnimation = SKAction.group([
            SKAction.repeatForever(soarAction),
            rotateDownAction
        ])
        // --- Create the taking damage animation ---
        let damageStart = SKAction.run {
            // Allow the penguin to pass through enemies
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPenguin.rawValue
        }
        // Create an opacity pulse, slow at first and fast at the end
        let slowFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.35),
            SKAction.fadeAlpha(to: 0.7, duration: 0.35)
        ])
        let fastFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 0.7, duration: 0.2)
        ])
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeat(slowFade, count: 2),
            SKAction.repeat(fastFade, count: 5),
            SKAction.fadeAlpha(to: 1, duration: 0.15)
        ])
        // Return the penguin to normal
        let damageEnd = SKAction.run {
            self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
            self.damaged = false
        }
        // Store the all sequence in a damageAnimatio property
        self.damageAnimation = SKAction.sequence([
            damageStart,
            fadeOutAndIn,
            damageEnd
        ])
        
        /* --- Create the death animation --- */
        let stardDie = SKAction.run {
            // Switch to the death texture with X eyes
            self.texture = self.textureAtlas.textureNamed("pierre-dead")
            // Suspend the penguin in space
            self.physicsBody?.affectedByGravity = false
            // Stop any movement
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        let endDie = SKAction.run {
            // Turn gravity back on
            self.physicsBody?.affectedByGravity = true
        }
        self.dieAnimation = SKAction.sequence([
            stardDie,
            // Scale the penguin bigger
            SKAction.scale(to: 1.3, duration: 0.5),
            // Use the WaitForDuration action to provide a shorto pause
            SKAction.wait(forDuration: 0.5),
            // Rotate the penguin on its back
            SKAction.rotate(toAngle: 3, duration: 1.5),
            SKAction.wait(forDuration: 0.5),
            endDie
        ])
    }
    // Implement onTap to conform to the GameSprite protocol
    func onTap() {}
    // Satisfy the NSCoder required init:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func update() {
        // If flapping, apply a new force to push Pierre higher.
        if self.flapping {
            var forceToApply = maxFlappingForce
            // Apply less force if Pierre is above position 600
            if position.y > 600 {
                // The higher Pierre goes, the more force we
                // remove. These next three lines determine the
                // force to subtract:
                let percentageOfMaxHeight = position.y / maxHeight
                let flappingForceSubtraction =
                percentageOfMaxHeight * maxFlappingForce
                forceToApply -= flappingForceSubtraction
            }
            // Apply the final force:
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: forceToApply))
        }
        // Limit Pierre's top speed as he climbs the y-axis.
        // This prevents him from gaining enough momentum to shoot
        // over our max height. We bend the physics for game play:
        if self.physicsBody!.velocity.dy > 300 {
            self.physicsBody!.velocity.dy = 300
        }
        // Set a constant velocity to the right:
        self.physicsBody?.velocity.dx = self.forwardVelocity
    }
    // Begin the flap animation, set flapping to true:
    func startFlapping() {
        if self.health <= 0 { return }
        self.removeAction(forKey: "soarAnimation")
        self.run(flyAnimation, withKey: "flapAnimation")
        self.flapping = true
    }
    // Stop the flap animation, set flapping to false:
    func stopFlapping() {
        if self.health <= 0 { return }
        self.removeAction(forKey: "flapAnimation")
        self.run(soarAnimation, withKey: "soarAnimation")
        self.flapping = false
    }
    
    func die() {
        self.alpha = 1
        self.removeAllActions()
        self.run(self.dieAnimation)
        self.flapping = false
        self.forwardVelocity = 0
        // Alert the GameScene:
        if let gameScene = self.parent as? GameScene {
            gameScene.gameOver()
        }
    }
    
    func takeDamage() {
        if self.invulnerable || self.damaged { return }
        self.damaged = true
        health -= 1
        if self.health == 0 {
            die()
        } else {
            self.run(self.damageAnimation)
        }
        // Play the hurt sound:
        self.run(hurtSound)
    }
    func starPower() {
        // Remove any existing star power-up animation, if the player is already under the power of a star
        self.removeAction(forKey: "starPower")
        // Grant great forward speed
        self.forwardVelocity = 400
        // Make the player invulnerable
        self.invulnerable = true
        // Create a sequence to scale the player larger, wait 8 seconds, then scale it back down and turn off invulnerability
        let starSequence = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.wait(forDuration: 8),
            SKAction.scale(to: 1, duration: 1),
            SKAction.run {
                self.forwardVelocity = 200
                self.invulnerable = false
            }
        ])
        // Execute the sequence
        self.run(starSequence, withKey: "starPower")
        
        // Play the powerup sound:
        self.run(powerupSound)
    }
}
