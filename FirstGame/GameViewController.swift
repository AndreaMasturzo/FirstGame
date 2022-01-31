//
//  GameViewController.swift
//  TestGame
//
//  Created by Andrea Masturzo on 27/12/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode fit the window:
                scene.scaleMode = .aspectFill
                // Size our scene to fit the view exactly:
                scene.size = view.bounds.size
                // Show the new scene:
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        } }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
        }
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
