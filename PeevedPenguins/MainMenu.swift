//
//  MainMenu.swift
//  PeevedPenguins
//
//  Created by Nursultan Askarbekuly on 27/06/2017.
//  Copyright © 2017 Nursultan Askarbekuly. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        playButton.selectedHandler = {
            self.loadGame()
        }
    }
    
    func loadGame() {
        guard let skView = self.view as SKView! else {
            print("Could not get SKView")
            return
        }
        
        guard let scene = GameScene.level(1) else {
            print("Could not get GameScene")
            return
        }
        
        scene.scaleMode = .aspectFit
        
//        skView.showsPhysics = true
//        skView.showsDrawCount = true
//        skView.showsFPS = true
        
        skView.presentScene(scene)
    }
}
