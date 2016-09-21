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
            filter.addTarget(outputView)
            spookiness = 1
        }
        running = (newWindow != nil)
    }
    
    var setupYet = false
    
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
        camera!.addTarget(filter)
        camera!.outputImageOrientation = .portrait
    }
    
    func stopRunning() {
        camera?.stopCapture()
        camera?.removeAllTargets()
    }
    
    var camera: GPUImageStillCamera?
    
    let outputView = GPUImageView()
    let filter = SpookyFilter(fragmentShaderFromFile: "Spooky")!
    
    var spookiness: Float = 0 {
        didSet {
            filter.spookiness = spookiness
        }
    }
}
