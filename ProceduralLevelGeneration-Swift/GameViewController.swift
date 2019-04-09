//
//  GameViewController.swift
//  ProceduralLevelGeneration-Swift
//
//  Created by iOS Bucky on 7/16/15.
//  Copyright (c) 2015 iOS Bucky. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var backgroundMusicPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = MyScene(size: view.bounds.size)
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        // Play some lovely background music

        let backgroundMusicURL = Bundle.main.url(forResource: "SillyFun", withExtension: "mp3")
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.volume = 0.2
        backgroundMusicPlayer?.prepareToPlay()
        backgroundMusicPlayer?.play()
    
        
        skView.presentScene(scene)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }


}
