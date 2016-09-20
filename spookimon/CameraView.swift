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
            
            rgbAdjust.addTarget(vignette)
            vignette.addTarget(blur)
            vignette.addTarget(mix)
            blur.addTarget(mix)
            mix.addTarget(outputView)
            
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
        camera!.addTarget(rgbAdjust)
        camera!.outputImageOrientation = .portrait
    }
    
    func stopRunning() {
        camera?.stopCapture()
        camera?.removeAllTargets()
    }
    
    var camera: GPUImageStillCamera?
    
    let outputView = GPUImageView()
    let rgbAdjust = GPUImageRGBFilter()
    let vignette = GPUImageVignetteFilter()
    let blur = GPUImageZoomBlurFilter()
    let mix = GPUImageAlphaBlendFilter()
    
    var spookiness: Float = 0 {
        didSet {
            let s = CGFloat(spookiness)
            rgbAdjust.red = 1 - s * 0.3
            rgbAdjust.green = 1 - s * 0.3
            rgbAdjust.blue = 1 - s * 0.15
            vignette.vignetteEnd = 1
            vignette.vignetteStart = 1 - 0.4 * s
            mix.mix = s * 0.3
        }
    }
}
