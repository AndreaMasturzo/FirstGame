//
//  Background.swift
//  FirstGame
//
//  Created by Andrea Masturzo on 01/02/22.
//

import Foundation
import SpriteKit

class Background: SKSpriteNode {
    // movementMultiplier will store a float from 0-1 to indicate how fast the background should move past
    // 0 is full of adjustment, no movement as the world goes past
    // 1 is no adjustment, background passes at normal speed
    var movementMultiplier = CGFloat(0)
    // jumpAdjustment will store how many points of x position this background has jumped forward
    var jumpAdjustment = CGFloat(0)
    // A constant for background node size
    let backgroundSize = CGSize(width: 1024, height: 768)
    // Store the background texture
    var textureAtlas = SKTextureAtlas(named: "Backgrounds")
    
    func spawn(parentNode: SKNode, imageName: String, zPosition: CGFloat, movementMultiplier: CGFloat) {
        // Position from the bottom left
        self.anchorPoint = CGPoint.zero
        // Starat background at the top of the ground
        self.position = CGPoint(x: 0, y: 30)
        // Control the order of the background with zPosition
        self.zPosition = zPosition
        // Store the movement multiplier
        self.movementMultiplier = movementMultiplier
        // Add the background to the parent node
        parentNode.addChild(self)
        // Grab the texture from the atlas
        let texture = textureAtlas.textureNamed(imageName)
        
        // Build three child node instances of the texture, looping from -1 to 1 so the backgrounds cover both forward and behind the player at position 0
        for i in -1...1 {
            let newBGnode = SKSpriteNode(texture: texture)
            let newBGNode = SKSpriteNode(texture: texture)
            // Set the size for this node from constant:
            newBGNode.size = backgroundSize
            // Position these nodes by their lower left corner:
            newBGNode.anchorPoint = CGPoint.zero
            // Position this background node:
            newBGNode.position = CGPoint(
                x: i * Int(backgroundSize.width), y: 0)
            // Add the node to the Background:
            self.addChild(newBGNode)
            
        }
    }
    
    
    // We will call updatePosition every frame to
    // reposition the background:
    func updatePosition(playerProgress: CGFloat) {
        // Calculate a position adjustment after loops and
        // parallax multiplier:
        let adjustedPosition = jumpAdjustment + playerProgress *
        (1 - movementMultiplier)
        // Check if we need to jump the background forward:
        if playerProgress - adjustedPosition >
            backgroundSize.width {
            jumpAdjustment += backgroundSize.width
        }
        // Adjust this background position forward as the camera
        // pans so the background appears slower:
        self.position.x = adjustedPosition
    }
}

