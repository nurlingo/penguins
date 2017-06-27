//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Nursultan Askarbekuly on 27/06/2017.
//  Copyright © 2017 Nursultan Askarbekuly. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var catapultArm: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        catapultArm = self.childNode(withName: "catapultArm") as! SKSpriteNode
    }
    
    let launchImpulse = CGVector(dx: 200, dy: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let penguin = Penguin()
        
        addChild(penguin)
        penguin.position.x = catapultArm.position.x + 32
        penguin.position.y = catapultArm.position.y + 50
        penguin.physicsBody?.applyImpulse(launchImpulse)
    
    
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
