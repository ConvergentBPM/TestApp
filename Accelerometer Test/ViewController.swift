//
//  ViewController.swift
//  Accelerometer Test
//
//  Created by Peter Cardenas on 10/11/19.
//  Copyright © 2019 Peter Cardenas. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var acceleration: UILabel!
    @IBOutlet weak var deviceMotion: UILabel!
    var motion = CMMotionManager()
    var pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        acceleration!.numberOfLines = 0
        deviceMotion!.numberOfLines = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAccelerometer()
        startMotionCapture()
    }
    
    func calculateSteps() {
        
    }
    
    func startAccelerometer() {
        motion.accelerometerUpdateInterval = 0.01
        motion.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            if let trueData = data {
                self.view.reloadInputViews()
                let x = String(format: "%.3f", trueData.acceleration.x * 9.8)
                let y = String(format: "%.3f", trueData.acceleration.y * 9.8)
                let z = String(format: "%.3f", trueData.acceleration.z * 9.8)
                let absolute = sqrt(pow(trueData.acceleration.x * 9.8, 2) + pow(trueData.acceleration.y * 9.8, 2) + pow(trueData.acceleration.z * 9.8, 2)) - 9.8
                let absStr = String(format: "%.3f", absolute)
                self.acceleration!.text = "x: \(x)\ny: \(y)\nz: \(z)\nabsolute: \(absStr)"
            }
        }
    }
    
    func startMotionCapture() {
        motion.deviceMotionUpdateInterval  = 0.01
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) {
            (data, error) in
            if let trueData = data {
                self.view.reloadInputViews()
                let x = String(format: "%.3f", trueData.attitude.pitch)
                let y = String(format: "%.3f", trueData.attitude.roll)
                let z = String(format: "%.3f", trueData.attitude.yaw)
                self.deviceMotion!.text = "x: \(x)\ny: \(y)\nz: \(z)\n"
                
            }
        }
    }
    
}

