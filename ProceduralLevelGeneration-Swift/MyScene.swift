//
//  MyScene.swift
//  ProceduralLevelGeneration-Swift
//
//  Created by iOS Bucky on 7/16/15.
//  Copyright (c) 2015 iOS Bucky. All rights reserved.
// https://github.com/iosbucky/ProceduralLevelGeneration-Swift

import SpriteKit

struct CollisionType {
    static let Player: UInt32  = 0x1 << 0
    static let Wall: UInt32    = 0x1 << 1
    static let Exit: UInt32    = 0x1 << 2
}

class MyScene: SKScene, SKPhysicsContactDelegate {

    let playerMovementSpeed: CGFloat = 100.0
    
    var lastUpdateTimeInterval = TimeInterval(0)
    
    // Add a node for the world - this is where sprites and tiles are added
    let world = SKNode()
    
    // Create a node for the HUD - this is where the DPad to control the player sprite will be added
    let hud = SKNode()
    
    let dPad: DPad!
    let map: Map
    let exit: SKSpriteNode!
    let spriteAtlas: SKTextureAtlas!
    let player: SKSpriteNode!
    let playerShadow: SKSpriteNode!
    var isExitingLevel = false
    var playerIdleAnimationFrames = Array<SKTexture>()
    var playerWalkAnimationFrames = Array<SKTexture>()
    var playerAnimationID: Int = 0          // 0 = idle; 1 = walk
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        
        // Load the atlas that contains the sprites
        spriteAtlas = SKTextureAtlas(named: "sprites")
        

        // Create a new map
        map = Map(gridSize: CGSize(width: 48, height: 48))
        map.maxFloorCount = 100
        map.turnResistance = 20
        map.floorMakerSpawnProbability = 25
        map.maxFloorMakerCount = 5
        map.roomProbability = 20
        map.roomMinSize = CGSize(width: 2, height: 2)
        map.roomMaxSize = CGSize(width: 6, height: 6)
        map.generate()

        // Create the exit
        exit = SKSpriteNode(texture: spriteAtlas.textureNamed("exit"))
        exit.position = map.exitPoint
        exit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: exit.texture!.size().width - 16, height: exit.texture!.size().height - 16))
        exit.physicsBody?.categoryBitMask = CollisionType.Exit
        exit.physicsBody?.collisionBitMask = 0
        

        // Create a player node
        player = SKSpriteNode(texture: spriteAtlas.textureNamed("idle_0"))
        player.position = map.spawnPoint
        player.physicsBody = SKPhysicsBody(rectangleOf: player.texture!.size())
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = CollisionType.Player
        player.physicsBody?.contactTestBitMask = CollisionType.Exit
        player.physicsBody?.collisionBitMask = CollisionType.Wall

        // Load sprites for player into arrays for the animations
        playerIdleAnimationFrames.append(spriteAtlas.textureNamed("idle_0"))

        playerWalkAnimationFrames.append(spriteAtlas.textureNamed("walk_0"))
        playerWalkAnimationFrames.append(spriteAtlas.textureNamed("walk_1"))
        playerWalkAnimationFrames.append(spriteAtlas.textureNamed("walk_2"))

        playerShadow = SKSpriteNode(texture: spriteAtlas.textureNamed("shadow"))
        playerShadow.xScale = 0.6
        playerShadow.yScale = 0.5
        playerShadow.alpha = 0.4

        world.addChild(map)
        world.addChild(exit)
        world.addChild(playerShadow)
        world.addChild(player)

        // Create the DPads
        dPad = DPad(rect: CGRect(x:0, y:0, width:64, height:64))
        dPad.position = CGPoint(x:64.0 / 4, y:64.0 / 4)
        dPad.numberOfDirections = 24
        dPad.deadRadius = 8.0

        hud.addChild(dPad)
        
        super.init(size: size)

        backgroundColor = SKColor(red: 175.0/255.0, green: 143.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        
        // Add the world and hud nodes to the scene
        addChild(world)
        addChild(hud)
        
        // Initialize physics
        physicsWorld.gravity = CGVector(dx:0, dy:0)
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        
        lastUpdateTimeInterval = currentTime
        
        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        
        // Poll the DPad
        let playerVelocity = isExitingLevel ? CGPoint.zero : dPad.velocity
        
        // Update player sprite position and orientation based on DPad input
        player.position = CGPoint(x: player.position.x + playerVelocity.x * CGFloat(timeSinceLast) * playerMovementSpeed, y: player.position.y + playerVelocity.y * CGFloat(timeSinceLast) * playerMovementSpeed)
        
        if ( playerVelocity.x != 0.0 )
        {
            player.xScale = (playerVelocity.x > 0.0) ? -1.0 : 1.0
        }
        
        // Ensure correct animation is playing
        playerAnimationID = playerVelocity.x != 0.0 ? 1 : 0
        
        resolveAnimationWithID(animationID: playerAnimationID)
        
        // Move "camera" so the player is in the middle of the screen
        self.world.position = CGPoint(x:-self.player.position.x + self.frame.midX, y:-self.player.position.y + self.frame.midY)

    }
    
    override func didSimulatePhysics() {
        player.zRotation = 0.0
        
        // Sync player with player sprite
        playerShadow.position = CGPoint(x: player.position.x, y: player.position.y - 7)
    }
    
    private func resolveAnimationWithID(animationID: Int) {
        var animationKey: String?
        var animationFrames: Array<SKTexture>?
        
        switch animationID {
        case 0:
            // Idle
            animationKey = "anim_idle"
            animationFrames = playerIdleAnimationFrames
        case 1:
            // Walk
            animationKey = "anim_walk"
            animationFrames = playerWalkAnimationFrames
        default:
            break
        }
        
        var animAction = player.action(forKey: animationKey!)
        
        // If this animation is already running or there are no frames we exit
        if animAction != nil  || animationFrames!.count < 1 {
            return
        }
        
        animAction = SKAction.animate(with: animationFrames!, timePerFrame: 5.0/60.0, resize: true, restore: false)
        if animationID == 1 {
            // Append sound for walking
            animAction = SKAction.group([animAction!, SKAction.playSoundFileNamed("step.wav", waitForCompletion: false)])
        }
        
        player.run(animAction!, withKey: animationKey!)
    }

    private func resolveExit() {
        
        // Disables DPad
        isExitingLevel = true
        
        // Remove shadow
        playerShadow.removeFromParent()
        
        // Animations
        let moveAction = SKAction.move(to: map.exitPoint, duration: 0.5)
        let rotateAction = SKAction.rotate(byAngle: CGFloat(Double.pi * 2), duration: 0.5)
        let fadeAction = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let scaleAction = SKAction.scaleX(to: 0.0, duration: 0.5)
        let soundAction = SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)
        let blockAction = SKAction.run( {
            self.view?.presentScene(MyScene(size: self.size), transition: SKTransition.doorsCloseVertical(withDuration: 0.5))
        })
        
        let exitAnimAction = SKAction.sequence([SKAction.group([moveAction, rotateAction, fadeAction, scaleAction, soundAction]), blockAction])
        player.run(exitAnimAction)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody?
        var secondBody: SKPhysicsBody?
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if firstBody!.categoryBitMask & CollisionType.Player != 0 && secondBody!.categoryBitMask & CollisionType.Exit != 0 {
            // Player reached exit
            resolveExit()
        }
    }
}


