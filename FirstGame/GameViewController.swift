//
//  GameViewController.swift
//  TestGame
//
//  Created by Andrea Masturzo on 27/12/21.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Build the menu scene:
        let menuScene = MenuScene()
        let skView = self.view as! SKView
        // Ignore drawing order of child nodes
        // (This increases performance)
        skView.ignoresSiblingOrder = true
        // Size our scene to fit the view exactly:
        menuScene.size = view.bounds.size
        // Show the menu:
        skView.presentScene(menuScene)
        
        // Start the background music:
        BackgroundMusic.instance.playBackgroundMusic()
        
    }
    
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
