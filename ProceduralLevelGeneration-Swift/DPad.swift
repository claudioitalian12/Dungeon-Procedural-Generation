//
//  DPad.swift
//  ProceduralLevelGeneration-Swift
//
//  Created by iOS Bucky on 7/16/15.
//  Copyright (c) 2015 iOS Bucky. All rights reserved.
//

import SpriteKit

class DPad : SKNode {

    let M_PI_X2: CGFloat = CGFloat(Double.pi) * 2
    let RAD_2_DEG: CGFloat = 180.0 / CGFloat(Double.pi)
    let DEG_2_RAD: CGFloat = CGFloat(Double.pi) / 180.0
    
    var stickPosition: CGPoint = CGPoint.zero
    var degrees = CGFloat(0)
    var velocity = CGPoint.zero
    
    var autoCenter = true
    var hasDeadzone = false         // Turns deadzone on/off for joystick, always YES if isDPad == YES
    var numberOfDirections = 8      // Only used when isDPad == YES
    
    var joystickRadius = CGFloat(0)
    var thumbRadius = CGFloat(32.0)
    var deadRadius = CGFloat(0)     // Size of deadzone in joystick (how far you must move before input starts). Automatically set is isDPad == YES
    
    
    var isDPad = true {
        didSet {
            if isDPad {
                hasDeadzone = true
                deadRadius = 10.0
            }
        }
    }
    
    let base = SKShapeNode()
    let stick = SKShapeNode()
    
    // Touch handling
    var isTouching = false
    var trackedTouches = Set<UITouch>()
    

    
    // Optimizations (keep squared values of all radii for faster calculations (updated internally when changing joy/thumb radii)
    var joystickRadiusSq: CGFloat {
        return joystickRadius * joystickRadius
    }
    var thumbRadiusSq: CGFloat {
        return thumbRadius * thumbRadius
    }
    var deadRadiusSq: CGFloat {
        return deadRadius * deadRadius
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(rect: CGRect) {
        super.init()
        
        joystickRadius = rect.width / 2
        
        // Set position of node
        self.position = rect.origin
        
        // Create base node
        base.fillColor = UIColor.gray
        base.strokeColor = UIColor.clear
        base.lineWidth = 0.0
        base.path = CGPath(ellipseIn: rect, transform: nil)
        base.alpha = 0.5
        
        addChild(base)
        
        // Create stick node
        stick.fillColor = UIColor.gray
        stick.strokeColor = UIColor.clear
        stick.lineWidth = 0.0
       ////////////controlla HFIGWHFWIFW
        stick.path = CGPath(ellipseIn: CGRect(x: rect.width / 4, y: rect.height / 4, width: rect.width, height: rect.height), transform: nil)
        
        addChild(stick)
        
        // Enable touch
        self.isUserInteractionEnabled = true
    }

    func updateVelocity(point: CGPoint) {
        // Calculate the distance and angle from center
        var dx = point.x
        var dy = point.y
        let dSq = dx * dx + dy * dy
        
        if dSq <= deadRadiusSq {
            velocity = CGPoint.zero
            degrees = 0.0
            updateStickPosition(point: point)
            return
        }
        
        var angle = CGFloat(atan2f(Float(dy), Float(dx)))       // in radians
        
        if angle < 0 {
            angle += M_PI_X2
        }
        
        if isDPad {
            let anglePerSector = 360.0 / CGFloat(numberOfDirections) * DEG_2_RAD
            angle = CGFloat(roundf(Float(angle) / Float(anglePerSector)) * Float(anglePerSector))
        }
        
        let cosAngle = CGFloat(cosf(Float(angle)))
        let sinAngle = CGFloat(sinf(Float(angle)))
        
        // Note: Velocity goes from -1.0 to 1.0
        if dSq > joystickRadiusSq || isDPad {
            dx = cosAngle * joystickRadius
            dy = sinAngle * joystickRadius

        }
        
        velocity = CGPoint(x: dx / joystickRadius, y: dy / joystickRadius)
        degrees = angle * RAD_2_DEG
        
        updateStickPosition(point: CGPoint(x: dx, y: dy))
    }

    func updateStickPosition(point: CGPoint) {
        stickPosition = point
        stick.position = stickPosition
    }

    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
                // First determine if the touch is within the boundries of the DPad
                var location = touch.location(in: self)
                location = CGPoint(x: location.x - joystickRadius, y: location.y - joystickRadius)
                
                if ( !(location.x < -joystickRadius || location.x > joystickRadius || location.y < -joystickRadius || location.y > joystickRadius) ){
                    let dSq = location.x * location.x + location.y * location.y
                    if joystickRadiusSq > dSq {
                        // Start tracking this touch
                        trackedTouches.insert(touch)
                        
                        // Signal that we ahve started tracking touches
                        isTouching = true
                        
                        // Update the DPad
                        updateVelocity(point: location)

                    }
                }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Only process if we are tracking touches
        if isTouching {
            for touch in touches {
             
                    // Determine if any of the touches are one of those being tracked
                    if trackedTouches.contains(touch) {
                        // This touch is being tracked
                        var location = touch.location(in: self)
                        location = CGPoint(x: location.x - joystickRadius, y: location.y - joystickRadius)
                        
                        updateVelocity(point: location)
                    }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching {
            for touch in touches {
              
                    
                    // Determine if this is a tracked touch
                    if trackedTouches.contains(touch) {
                        
                        // This touch was being tracked
                        var location = CGPoint.zero
                        
                        if !autoCenter {
                            location = touch.location(in: self)
                            location = CGPoint(x: location.x - joystickRadius, y: location.y - joystickRadius)
                        }
                        updateVelocity(point: location)
                        
                        // Remove the touch as we are no longer tracking it
                        trackedTouches.remove(touch)

                    }
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
}
