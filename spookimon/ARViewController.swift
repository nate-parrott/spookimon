//
//  ViewController.swift
//  pokemon
//
//  Created by Nate Parrott on 7/11/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import ModelIO

class ARViewController: UIViewController {

    let sceneView = SCNView()
    let scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    let motionManager = CMMotionManager()
    let cameraView = CameraView()
    // -z is the floor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insertSubview(cameraView, at: 0)
        cameraView.frame = view.bounds
        cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraView.startRunning()
        
        view.insertSubview(sceneView, at: 1)
        sceneView.frame = view.bounds
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.red
        
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        // let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let assetURL = Bundle.main.url(forResource: "landlord_triangulated", withExtension: "dae")!
        let asset = try! SCNScene(url: assetURL, options: nil).rootNode.childNodes[0]
        asset.position = SCNVector3Make(0, 5, -2)
        // murray.rotation = SCNVector4Make(1, 1, 1, Float(M_PI) / 3)
        // murray.scale = SCNVector3Make(0.06, 0.06, 0.06)
        scene.rootNode.addChildNode(asset)
        
        let sun = SCNLight()
        sun.type = SCNLight.LightType.omni
        sun.color = UIColor(white: 1, alpha: 0.2)
        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.position = SCNVector3Make(0, 0, 10)
        scene.rootNode.addChildNode(sunNode)
        
        let ambient = SCNLight()
        ambient.type = SCNLight.LightType.ambient
        ambient.color = UIColor(white: 1, alpha: 0.2)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motionOpt, _) in
            if let motion = motionOpt {
                self.cameraNode.orientation = motion.attitude.quaternion.scnQuaternion
            }
        }
    }

    
    @IBOutlet var spookinessSlider: UISlider?
    @IBAction func updateSpookiness() {
        cameraView.spookiness = spookinessSlider?.value ?? 0
    }
}

extension CMQuaternion {
    var scnQuaternion: SCNQuaternion {
        get {
            return SCNVector4Make(Float(x), Float(y), Float(z), Float(w))
        }
    }
}

