//
//  CameraView.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class CameraView: UIView {
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if !setupYet {
            setupYet = true
            addSubview(outputView)
            outputView.frame = bounds
            outputView.transform = CGAffineTransform(scaleX: 1, y: -1)
            outputView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
            spookiness = 1
            buildPipeline()
        }
        running = (newWindow != nil)
    }
    var setupYet = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        outputView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        outputView.bounds = bounds
    }
    
    func buildPipeline() {
        flip.affineTransform = CGAffineTransform(scaleX: 1, y: -1) // .translatedBy(x: 0, y: 1)
        flip.ignoreAspectRatio = true
        flip.addTarget(mix, atTextureLocation: 0)
        arTextureInput.addTarget(mix, atTextureLocation: 1)
        mix.addTarget(filter)
        filter.addTarget(outputView)
        // arTextureInput.addTarget(outputView)
    }
    
    var running: Bool = false {
        willSet(newVal) {
            if newVal != running {
                if newVal {
                    startRunning()
                } else {
                    stopRunning()
                }
            }
        }
    }
    
    func startRunning() {
        camera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetMedium, cameraPosition: .back)
        camera!.startCapture()
        camera!.addTarget(flip)
        camera!.outputImageOrientation = .portrait
    }
    
    func stopRunning() {
        camera?.stopCapture()
        camera?.removeAllTargets()
    }
    
    var camera: GPUImageStillCamera?
    
    let outputView = GPUImageView()
    let filter = SpookyFilter(fragmentShaderFromFile: "Spooky")!
    let mix = GPUImageNormalBlendFilter()
    let flip = GPUImageTransformFilter()
    let arTextureInput = GPUImageSceneKitOutput(size: UIScreen.main.bounds.size)!
    
    var spookiness: Float = 0 {
        didSet {
            filter.spookiness = spookiness
        }
    }
}
