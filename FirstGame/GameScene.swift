//
//  GameScene.swift
//  TestGame
//
//  Created by Andrea Masturzo on 27/12/21.
//

import SpriteKit
import CoreMotion


enum PhysicsCategory: UInt32 {
    case penguin = 1
    case damagedPenguin = 2
    case ground = 4
    case enemy = 8
    case coin = 16
    case powerup = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let powerUpStar = Star()
    var nextEncounterSpawnPosition = CGFloat(150)
    let encounterManager = EncounterManager()
    var screenCenterY: CGFloat = 0
    let initialPlayerPosition = CGPoint(x: 150, y: 250)
    var playerProgress = CGFloat()
    let motionManager = CMMotionManager()
    let cam = SKCameraNode()
    let ground = Ground()
    let player = Player()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue:
                                        0.95, alpha: 1.0)
        
        //Add the star:
        self.addChild(powerUpStar)
        powerUpStar.position = CGPoint(x: -2000, y: -2000)
        
        // Add the camera:
        self.camera = cam
        
        // Add the ground:
        ground.position = CGPoint(x: -self.size.width * 2, y: 30)
        ground.size = CGSize(width: self.size.width * 6, height: 0)
        ground.createChildren()
        self.addChild(ground)
        
        // Add the player to the scene:
        player.position = initialPlayerPosition
        self.addChild(player)
        
        
        // Set gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        // Store the vertical center of the screen:
        screenCenterY = self.size.height / 2
        
        // Let the manager know we want to poll the orientation data
        self.motionManager.startAccelerometerUpdates()
        // Unwrap the accelerometer data optional:
        if let accelData = self.motionManager.accelerometerData {
            var forceAmount: CGFloat
            var movement = CGVector()
            // Based on the device orientation, the tilt number
            // can indicate opposite user desires. The
            // UIApplication class exposes an enum that allows
            // us to pull the current orientation.
            // We will use this opportunity to explore Swift's
            // switch syntax and assign the correct force for the
            // current orientation:
            switch
            UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                // The 20,000 number is an amount that felt right
                // for our example, given Pierre's 30kg mass:
                forceAmount = 20000
            case .landscapeRight:
                forceAmount = -20000
            default:
                forceAmount = 0
            }
            // If the device is tilted more than 15% towards
            // vertical, then we want to move the Penguin:
            if accelData.acceleration.y > 0.15 {
                movement.dx = forceAmount
            }
            // Core Motion values are relative to portrait view.
            // Since we are in landscape, use y-values for x-axis.
            else if accelData.acceleration.y < -0.15 {
                movement.dx = -forceAmount
            }
            // Apply the force we created to the player:
            player.physicsBody?.applyForce(movement)
        }
        encounterManager.addEncountersToScene(gameScene: self)
        
        // Setting the GameScene physicsWorld property to the GameScene instance
        self.physicsWorld.contactDelegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        for touch in (touches) {
            // Find the location of the touch:
            let location = touch.location(in: self)
            // Locate the node at this location:
            let nodeTouched = atPoint(location)
            // Attempt to downcast the node to the GameSprite protocol
            if let gameSprite = nodeTouched as? GameSprite {
                // If this node adheres to GameSprite, call onTap:
                gameSprite.onTap()
            }
        }
        player.startFlapping()
    }
    
    override func didSimulatePhysics() {
        // Keep the camera locked at mid screen by default:
        var cameraYPos = screenCenterY
        cam.yScale = 1
        cam.xScale = 1
        // Follow the player up if higher than half the screen:
        if (player.position.y > screenCenterY) {
            cameraYPos = player.position.y
            // Scale out the camera as they go higher:
            let percentOfMaxHeight = (player.position.y -
                                      screenCenterY) / (player.maxHeight -
                                                        screenCenterY)
            let newScale = 1 + percentOfMaxHeight
            cam.yScale = newScale
            cam.xScale = newScale
        }
        
        // Move the camera for our adjustment:
        self.camera!.position = CGPoint(x: player.position.x, y: cameraYPos)
        
        // Keep track of how far the player has flown
        playerProgress = player.position.x - initialPlayerPosition.x
        
        // Check to see if the ground should jump forward:
        ground.checkForReposition(playerProgress: playerProgress)
        
        // Check to see if we should set a new encounter:
        if player.position.x > nextEncounterSpawnPosition {
            encounterManager.placeNextEncounter(currentXPos: nextEncounterSpawnPosition)
            nextEncounterSpawnPosition += 1200
            // Each encounter has a 10% chance to spawn a star:
            let starRoll = Int(arc4random_uniform(10))
            if starRoll == 0 {
                // Only move the star if it is off the screen.
                if abs(player.position.x - powerUpStar.position.x)
                    > 1200 {
                    // Y Position 50-450:
                    let randomYPos = 50 +
                    CGFloat(arc4random_uniform(400))
                    powerUpStar.position = CGPoint(x:
                                                    nextEncounterSpawnPosition, y: randomYPos)
                    // Remove any previous velocity and spin:
                    powerUpStar.physicsBody?.angularVelocity = 0
                    powerUpStar.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        player.update()
    }
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        player.stopFlapping()
    }
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        player.stopFlapping()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Each contact has two bodies, we do not know which is which.
        // We will find the penguin body first, then use the other body to determine the type of contact
        let otherBody: SKPhysicsBody
        // Combine the two penguin physics category into one bitmask with the bitwisw OR operator
        let penguinMask = PhysicsCategory.penguin.rawValue | PhysicsCategory.damagedPenguin.rawValue
        // Use the bitwise AND operator to find the penguin
        // This returns a positive number if body A's category is the same as penguin or damagedPenguin
        if (contact.bodyA.categoryBitMask & penguinMask) > 0 {
            // bodyA is the penguin, we will test bodyB's type
        otherBody = contact.bodyB
        } else {
            // bodyB is the penguin, we will test bodyA's type
            otherBody = contact.bodyA
        }
        // Find the type of contact
        switch otherBody.categoryBitMask {
        case PhysicsCategory.ground.rawValue: print("Hit the ground")
            player.takeDamage()
        case PhysicsCategory.enemy.rawValue: print("Take damage")
            player.takeDamage()
        case PhysicsCategory.coin.rawValue: print("Collect a coin")
        case PhysicsCategory.powerup.rawValue: print("Start the powerup")
        default: print("Contact with no game logic")
        }
    }
}
