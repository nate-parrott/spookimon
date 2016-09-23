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
import GPUImage

class ARViewController: UIViewController {

    let scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    let motionManager = CMMotionManager()
    let cameraView = CameraView()
    let renderer = SCNRenderer(context: GPUImageContext.sharedImageProcessing().context, options: nil)
    var displayLink: CADisplayLink!
    
    let curLoc = CurrentLocationObserver()
    // -z is the floor
    
    var billboards = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let motionEnabled = true
        
        view.insertSubview(cameraView, at: 0)
        cameraView.frame = view.bounds
        cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraView.startRunning()
        
        renderer.scene = scene
        
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
                
        // let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let assetURL = Bundle.main.url(forResource: "landlord_triangulated", withExtension: "dae")!
        let asset = try! SCNScene(url: assetURL, options: nil).rootNode.childNodes[0]
        asset.position = motionEnabled ? SCNVector3Make(0, 5, 0) : SCNVector3Make(0,0,-5)
        // murray.rotation = SCNVector4Make(1, 1, 1, Float(M_PI) / 3)
        // murray.scale = SCNVector3Make(0.06, 0.06, 0.06)
        scene.rootNode.addChildNode(asset)
        
        let plane = SCNPlane(width: 1, height: 1)
        let ghostChild = SCNNode(geometry: plane)
        let ghost = SCNNode()
        billboards.append(ghostChild)
        ghost.addChildNode(ghostChild)
        let ghostMtl = SCNMaterial()
        ghostMtl.diffuse.contents = UIImage(named: "ghost")!
        plane.materials = [ghostMtl]
        let position = SCNVector3Make(-4, 2.5, 0)
        let pi = Float(M_PI)
        let angle: Float = pi/2*0 - atan2(position.y, position.x)
        // SCNMatrix4MakeRotation(1, 0, 0, pi / 2)
        ghost.transform = SCNMatrix4Translate(
            SCNMatrix4Rotate(
                SCNMatrix4MakeRotation(pi / 2, 1, 0, 0),
                angle, 0, 0, 1),
            position.x, position.y, position.z)
        // ghost.rotation = SCNVector4Make(1, 0, 0, pi / 2)
        // x: left to right
        // y: front to back
        // z: down to up
        ghostMtl.isDoubleSided = true
        scene.rootNode.addChildNode(ghost)
        // let constraint = SCNBillboardConstraint()
//        constraint.freeAxes = SCNBillboardAxis.Z
        // let constraint = SCNLookAtConstraint(target: cameraNode)
        // ghost.constraints = [constraint]
        // ghost.transform = SCNMatrix4Translate(SCNMatrix4FromGLKMatrix4(GLKMatrix4MakeLookAt(0, 0, 0, -ghost.position.x, -ghost.position.y, -ghost.position.z, 0, 0, 1)), ghost.position.x, ghost.position.y, ghost.position.z)
        
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
            if let motion = motionOpt, motionEnabled {
                self.cameraNode.orientation = motion.attitude.quaternion.scnQuaternion
            }
        }
        
        curLoc.onUpdate = {
            [weak self] in
            self?.settingUpdated()
        }
        settingUpdated()
        
        displayLink = CADisplayLink(target: self, selector: #selector(ARViewController.render))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    var time: CFTimeInterval = 0
    func render() {
        time += displayLink.duration
        runAsynchronouslyOnContextQueue(GPUImageContext.sharedImageProcessing()) {
            self.cameraView.arTextureInput.render(self.renderer, size: self.view.bounds.size, time: self.time)
        }
        // cameraView.arTextureInput.render(renderer, size: view.bounds.size, time: time)
//        runAsynchronouslyOnContextQueue(GPUImageContext.sharedImageProcessing()) {
//            GPUImageContext.useImageProcessingContext()
//            self.cameraView.arTextureInput.framebufferForOutput.activate()
//            self.renderer.render(atTime: self.time)
//            self.cameraView.arTextureInput.notifyTargetsAboutNewOutputTexture()
//        }
    }

    
    @IBOutlet var spookinessSlider: UISlider?
    @IBAction func updateSpookiness() {
        if let handle = curLoc.cellHandle {
            handle.spookiness = spookinessSlider?.value ?? 0
        }
    }
    
    func settingUpdated() {
        if let handle = curLoc.cellHandle {
            spookinessSlider?.value = handle.spookiness
            cameraView.spookiness = handle.spookiness
        }
    }
}

extension CMQuaternion {
    var scnQuaternion: SCNQuaternion {
        get {
            return SCNVector4Make(Float(x), Float(y), Float(z), Float(w))
        }
    }
}

