//
//  FloorMaker.swift
//  ProceduralLevelGeneration-Swift
//
//  Created by iOS Bucky on 7/16/15.
//  Copyright (c) 2015 iOS Bucky. All rights reserved.
//

import Foundation
import CoreGraphics

class FloorMaker {
    var currentPosition = CGPoint.zero
    var direction = 0
    
    init(currentPosition: CGPoint, direction: Int) {
        self.currentPosition = currentPosition
        self.direction = direction
    }
}
