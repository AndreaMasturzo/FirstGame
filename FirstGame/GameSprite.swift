//
//  GameSprite.swift
//  TestGame
//
//  Created by Andrea Masturzo on 29/12/21.
//

import Foundation
import SpriteKit
  protocol GameSprite {
  var textureAtlas: SKTextureAtlas { get set }
  var initialSize: CGSize { get set }
  func onTap()
  }
