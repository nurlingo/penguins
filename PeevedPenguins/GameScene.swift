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
    
    var restartButton: MSButtonNode!
    var cameraTarget: SKSpriteNode?
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    var touchJoint: SKPhysicsJointSpring?
    var level = 1
    
    override func didMove(to view: SKView) {
        setupCameraAndButtons(to: view)
        setupCatapult()
        
    }
    
    func setupCameraAndButtons(to view: SKView){
        cameraNode = self.childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        restartButton = cameraNode.childNode(withName: "restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            guard let scene = GameScene.level(self.level) else {return}
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
    }
    
    func setupCatapult() {
        catapultArm = self.childNode(withName: "catapultArm") as! SKSpriteNode
        catapult = self.childNode(withName: "catapult") as! SKSpriteNode
        cantileverNode = self.childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = self.childNode(withName: "touchNode") as! SKSpriteNode
        var pinLocation = self.catapultArm.position
        pinLocation.x += -10
        pinLocation.y += -70
        let catapultJoint = SKPhysicsJointPin.joint(withBodyA: catapult.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: pinLocation)
        self.physicsWorld.add(catapultJoint)
        
        var anchorPosition = catapultArm.position
        anchorPosition.x += 0
        anchorPosition.y += 50
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorPosition, anchorB: cantileverNode.position)
        self.physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
        
    }
    
    let launchImpulse = CGVector(dx: 400, dy: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let penguin = Penguin()
//        
//        addChild(penguin)
//        penguin.position.x = catapultArm.position.x + 32
//        penguin.position.y = catapultArm.position.y + 50
//        penguin.physicsBody?.applyImpulse(launchImpulse)
//        cameraTarget = penguin
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "catapultArm" {
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveCamera()
    }
    
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFill
        return scene
    }

    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value,lower),upper)
    }
    
}

