//
//  CameraView.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    
    override func willMove(toWindow newWindow: UIWindow?) {
        running = (newWindow != nil)
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
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    
    // MARK: setup
    
    func startRunning() {
        if let device = getDevice() {
            captureDevice = device
            self.configureCamera(captureDevice!)
            captureSession = AVCaptureSession()
            if captureSession!.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                captureSession!.sessionPreset = AVCaptureSessionPreset1920x1080
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            stillImageOutput = AVCaptureStillImageOutput()
            captureSession!.addOutput(stillImageOutput!)
            let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice!)
            captureSession!.addInput(captureDeviceInput)
            layer.addSublayer(previewLayer!)
            
            if let metadataDelegate = metadataObjectsDelegate {
                metadataOutput = AVCaptureMetadataOutput()
                captureSession!.addOutput(metadataOutput!)
                metadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                metadataOutput!.setMetadataObjectsDelegate(metadataDelegate, queue: DispatchQueue.main)
            }
            
            captureSession!.startRunning()
        }
    }
    
    func getDevice() -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice] {
            if device.position == AVCaptureDevicePosition.back {
                return device
            }
        }
        return nil
    }
    
    func configureCamera(_ camera: AVCaptureDevice) {
        do {
            try camera.lockForConfiguration()
            if camera.isAutoFocusRangeRestrictionSupported {
                camera.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.near
            }
            if camera.isLowLightBoostSupported {
                camera.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    // MARK: teardown
    
    func stopRunning() {
        if let session = captureSession {
            session.stopRunning()
            captureDevice = nil
            captureSession = nil
            previewLayer = nil
            stillImageOutput = nil
            metadataOutput = nil
        }
    }
    
    // MARK: layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if let p = previewLayer {
            p.frame = bounds
        }
    }
    
    // MARK: metadata output
    @IBOutlet var metadataObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
}
