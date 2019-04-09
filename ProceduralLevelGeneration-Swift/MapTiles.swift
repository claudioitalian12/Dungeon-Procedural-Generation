//
//  MapTiles.swift
//  ProceduralLevelGeneration-Swift
//
//  Created by iOS Bucky on 7/16/15.
//  Copyright (c) 2015 iOS Bucky. All rights reserved.
//

import Foundation
import CoreGraphics

enum MapTileType: Int {
    case Invalid = -1
    case None = 0
    case Floor = 1
    case Wall = 2
}

class MapTiles {
    var gridSize = CGSize.zero
    
    private var tiles = [MapTileType]()
    
    init(gridSize: CGSize) {
        self.gridSize = gridSize
      
        var b = [MapTileType]()
        for _ in 0...Int(gridSize.height * gridSize.width){
            let bx = MapTileType(rawValue: 0)
            b.append(bx!)
        }
        
        tiles = b
    }

    func isValidTileCoordinateAt(tileCoordinate: CGPoint) -> Bool {
        return !(tileCoordinate.x < 0 || tileCoordinate.x >= gridSize.width || tileCoordinate.y < 0 || tileCoordinate.y >= gridSize.height)
    }
    
    func tileIndexAt(tileCoordinate: CGPoint) -> Int {
        if !isValidTileCoordinateAt(tileCoordinate: tileCoordinate) {
            return -1
        }
        return Int(tileCoordinate.y) * Int(gridSize.width) + Int(tileCoordinate.x)
    }

    func tileTypeAt(tileCoordinate: CGPoint) -> MapTileType {
        let tileArrayIndex = tileIndexAt(tileCoordinate: tileCoordinate)
        if tileArrayIndex == -1 {
            NSLog("Not a valid tile coordinate at %.0f,%.0f", tileCoordinate.x, tileCoordinate.y)
            return .Invalid
        }
        return tiles[tileArrayIndex]
    }
    
    func setTileType(type: MapTileType, atTileCoordinate tileCooridinate: CGPoint) {
        let tileArrayIndex = tileIndexAt(tileCoordinate: tileCooridinate)
        if tileArrayIndex == -1 {
            return
        }
        tiles[tileArrayIndex] = type
    }
    
    func isEdgeTileAt(tileCoordinate: CGPoint) -> Bool {
        return tileCoordinate.x == 0 || tileCoordinate.x == gridSize.width - 1 || tileCoordinate.y == 0 || tileCoordinate.y == gridSize.height - 1
    }
    
    var description: String {
       
        var tileMapDescription = String(format: "<MapTiles = %p | \n", ObjectIdentifier(self).debugDescription)
     
        for y in (0 ..< Int(gridSize.width) - 1).reversed() {
            tileMapDescription += "[\(y)]"
            for x in 0 ..< Int(gridSize.height) {
                tileMapDescription += "\(tileTypeAt(tileCoordinate: CGPoint(x: x, y: y)).rawValue)"
            }
            tileMapDescription += "\n"
        }
     return tileMapDescription
    }
}
