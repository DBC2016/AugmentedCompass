//
//  ViewController.swift
//  AugmentedCompass
//
//  Created by Demond Childers on 5/23/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    var mapView      :UIView!
    
    
    //MARK: - COMPASS METHODS
    
    var locationManger = CLLocationManager()
    @IBOutlet var headingLabel :UILabel!
    
    @IBAction private func startGettingHeading() {
        locationManger.delegate = self
        locationManger.startUpdatingHeading()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var headingString = ""
        switch newHeading.magneticHeading {
        case 0...22.5:
            headingString = "N"
        case 22.5...67.5:
            headingString = "NE"
        case 67.5...112.5:
            headingString = "E"
        case 112.5...157.5:
            headingString = "SE"
        case 157.5...202.5:
            headingString = "S"
        case 202.5...247.5:
            headingString = "SW"
        case 247.5...292.5:
            headingString = "W"
        case 292.5...337.5:
            headingString = "NW"
        case 337.5...360.0:
            headingString = "N"
        default:
            headingString = "?"
        }
        let wholeDegrees = String(format: "%0.f", newHeading.magneticHeading)
        headingLabel.text = "\(headingString) \(wholeDegrees) degrees"
    }
    
    @IBAction private func stopGettinghHeading(sender: UIButton) {
        locationManger.stopUpdatingHeading()
    }
    

    
    //MARK: - MANUAL CAMERA METHODS
    
    
    @IBOutlet private weak var previewView :UIView!
    var captureSession      :AVCaptureSession?
    var previewLayer        :AVCaptureVideoPreviewLayer?
    var stillImageOutput    :AVCaptureStillImageOutput?
    
    func startCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error   :NSError?
        var input   :AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print("Error \(error)")
            
        }
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            //Code that prepares to take Photo
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
            }
            
            //Code that shows how Photo is Displayed
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.connection?.videoOrientation = .Portrait
            previewView.layer.addSublayer(previewLayer!)
            
            captureSession!.startRunning()
            
            
        }
        
    }
    
    //Code gives access to what's being displayed at the moment
    
//    @IBAction private func didPressTakePhotoButton(sender: UIBarButtonItem) {
//        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
//            videoConnection.videoOrientation = .Portrait
//            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
//                if sampleBuffer != nil {
//                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
//                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
//                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation:  .Right)
//                    self.capturedImage.image = image
//                    
//                }
//            })
//            
//        }
//    }
    
    
    //MARK: - ROTATION ANGLE METHODS
    
    private var motionManager = CMMotionManager()
    private var timer: NSTimer?
    @IBOutlet private var angleLabel: UILabel!
    
    @IBAction private func startAngleFinder(sender: UIButton) {
        timer = NSTimer(timeInterval: 0.2, target: self, selector: #selector(getAngleInfo), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    @IBAction private func stopAngleFinder(sender: UIButton)    {
        if let uTimer = timer {
            uTimer.invalidate()
        }
    }
    
    func getAngleInfo() {
        guard let deviceMotion = motionManager.deviceMotion else {
            return
        }
        let currentGravity = deviceMotion.gravity
        let angleInRadians = atan2(currentGravity.y ,currentGravity.x)
        var angleInDegrees = (angleInRadians * 180.0 / M_PI)
        if  angleInDegrees <= -90 {
            angleInDegrees += 450
            
        } else {
            angleInDegrees += 90
        }
        angleLabel.text = "Angle: " + String(format: "%.0f", angleInDegrees) + " degrees"
        
    }


    
    
    //MARK: - LIFE CYCLE METHODS
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGettingHeading()
        startCaptureSession()
        
        //        motionManager.startDeviceMotionUpdates()
        
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

