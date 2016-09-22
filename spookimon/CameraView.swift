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
            outputView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            outputView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
            spookiness = 1
        }
        running = (newWindow != nil)
    }
    var setupYet = false
    
    func buildPipelineWithARTexture(texture: GLuint, size: CGSize) {
        arTextureInput = GPUImageTextureInput(texture: texture, size: size)
        arTextureInput.addTarget(mix, atTextureLocation: 1)
        mix.addTarget(filter)
        filter.addTarget(outputView)
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
        camera!.addTarget(mix, atTextureLocation: 0)
        camera!.outputImageOrientation = .portrait
    }
    
    func stopRunning() {
        camera?.stopCapture()
        camera?.removeAllTargets()
    }
    
    var camera: GPUImageStillCamera?
    
    let outputView = GPUImageView()
    let filter = SpookyFilter(fragmentShaderFromFile: "Spooky")!
    let mix = GPUImageAlphaBlendFilter()
    var arTextureInput: GPUImageTextureInput!
    
    var spookiness: Float = 0 {
        didSet {
            filter.spookiness = spookiness
        }
    }
}
