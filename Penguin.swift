//
//  Penguin.swift
//  PeevedPenguins
//
//  Created by Nursultan Askarbekuly on 27/06/2017.
//  Copyright © 2017 Nursultan Askarbekuly. All rights reserved.
//

import SpriteKit

class Penguin: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "flyingpenguin")
        let color = UIColor.clear
        let size = texture.size()
        
        super.init(texture: texture, color: color, size: size)
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.categoryBitMask = 1
        physicsBody?.friction = 0.6
        physicsBody?.mass = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
