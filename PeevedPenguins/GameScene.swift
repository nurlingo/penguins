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
    
    var level = 1
    var restartButton: MSButtonNode!
    var cameraTarget: SKSpriteNode?
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointPin?
    let sealDeathSound = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupCamera()
        setupButtons(to: view)
        setupCatapult()
    }
    
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func setupCamera(){
        cameraNode = self.childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
    }
    
    func setupButtons(to view: SKView){
        restartButton = cameraNode.childNode(withName: "restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            guard let scene = GameScene.level(self.level) else {return}
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
    }

    

    func setupCatapult() {
        catapultArm = self.childNode(withName: "catapultArm") as! SKSpriteNode
        catapultArm.physicsBody?.usesPreciseCollisionDetection = true
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
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        moveCamera()
        checkPenguinAdjustCamera()
    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 960+960-568)
        cameraNode.position.x = x
    }
    
    func checkPenguinAdjustCamera() {
        guard let cameraTarget = cameraTarget else { return }
        
        if cameraTarget.physicsBody!.joints.count == 0 && cameraTarget.physicsBody!.velocity.length() < 0.58 {
            resetCamera()
        }
        if cameraTarget.position.y < -200 {
            cameraTarget.removeFromParent()
            resetCamera()
        }
    }
    
    func resetCamera() {
        let cameraReset = SKAction.move(to: CGPoint(x:0,y:camera!.position.y), duration: 1.5)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
        cameraNode.run(cameraSequence)
        cameraTarget = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "catapultArm" {
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
            
            let penguin = Penguin()
            
            addChild(penguin)
            penguin.position.x = catapultArm.position.x + 30
            penguin.position.y = catapultArm.position.y + 50
            penguin.physicsBody?.categoryBitMask = 1
            penguin.physicsBody?.collisionBitMask = 14
            penguin.physicsBody?.usesPreciseCollisionDetection = true
            penguinJoint = SKPhysicsJointPin.joint(withBodyA: penguin.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: penguin.position)
            physicsWorld.add(penguinJoint!)
            cameraTarget = penguin
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
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        guard let penguin = cameraTarget else {return}
        let force: CGFloat = 150
        let r = catapultArm.zRotation
        let dx = cos(r)*force
        let dy = sin(r)*force
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyForce(v)
        
    }
    
    
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            if contact.collisionImpulse > 2.0{
                if contactA.categoryBitMask == 2 {removeSeal(node: nodeA)}
                if contactB.categoryBitMask == 2 {removeSeal(node: nodeB)}
            }
        }
    }
    
    func removeSeal(node: SKNode) {
        
        let sealDeath = SKAction.run { node.removeFromParent() }
        self.run(sealDeath)
        
        let particles = SKEmitterNode(fileNamed: "Poof")!
        particles.position = node.convert(node.position, to: self)
        addChild(particles)
        
        let wait = SKAction.wait(forDuration: 5)
        let removeParticles = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, removeParticles])
        particles.run(sequence)
        
        self.run(sealDeathSound)
        
        
    }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value,lower),upper)
}

extension CGVector {
    public func length() -> CGFloat {
        return CGFloat(sqrt(dx*dx + dy*dy))
    }
}

