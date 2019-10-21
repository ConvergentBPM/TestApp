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
    @IBOutlet weak var pedometerLabel: UILabel!
    var motion = CMMotionManager()
    var pedometer = CMPedometer()
    let endpoint : String = "http://10.147.159.179:5000"
    let authorizeEndpoint : String = "https://accounts.spotify.com/authorize"
    let SpotifyClientID : String = "085823f46ba74b50960597924a3c4416"
    let SpotifyRedirectURL = URL(string: "running-app://callback")!

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self as? SPTSessionManagerDelegate)
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        acceleration!.numberOfLines = 0
        deviceMotion!.numberOfLines = 0
        pedometerLabel!.numberOfLines = 0
        getAuthCodeRequest()
    }
    
    func getAuthCodeRequest() {
        print("start get request")
        let authCodeEndpoint = "\(authorizeEndpoint)?client_id=\(SpotifyClientID)&response_type=code&redirect_uri=\(SpotifyRedirectURL)&scope=\("user-read-private user-read-email")"
        guard let url = URL(string: authCodeEndpoint) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: req, completionHandler:{ data, response, error in
            // check for any errors
            guard error == nil else {
              print("error calling GET on /authorize")
              print(error!)
              return
            }
            // make sure we got data
            guard let responseData = data else {
              print("Error: did not receive data")
              return
            }
            // parse the result as JSON, since that's what the API provides
            do {
              guard let code = try JSONSerialization.jsonObject(with: responseData, options: [])
                as? [String: Any] else {
                print("error trying to convert data to JSON")
                return
              }
              print(code)
            } catch  {
              print("error trying to convert data to JSON")
              return
            }
        })
        task.resume()
    }
    
    func postRequest(data: [String: Any]) {
        guard let url = URL(string: endpoint) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        do {
            let json = try JSONSerialization.data(withJSONObject: data, options: [])
            req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            req.httpBody = json
        } catch {
          print("Error: cannot create JSON from todo")
          return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: req, completionHandler:{ _, _, _ in })
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let startDate = Date()
        updateStepsCountLabelUsing(startDate: startDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAccelerometer()
        startMotionCapture()
        if (CMPedometer.isStepCountingAvailable()) {
            calculateSteps()
        }
    }
    
    private func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            pedometerData, error in
            if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self.updatePedometerLabel(pedometerData: pedometerData)
                }
            }
        }
    }
    
    func updatePedometerLabel(pedometerData: CMPedometerData) {
        let totalNumSteps = pedometerData.numberOfSteps.stringValue
        var cadence = "0"
        if let currCadence = pedometerData.currentCadence {
            cadence = String(format: "%.3f", currCadence.floatValue * 60.0)
        }
        self.pedometerLabel.text = String(describing: "Number of steps: \(totalNumSteps)\n Steps per minute: \(cadence)")
    }
    
    func calculateSteps() {
        pedometer.startUpdates(from: Date()) { (data, error) in
            guard let pedometerData = data, error == nil else { return }
            DispatchQueue.main.async {
                self.updatePedometerLabel(pedometerData: pedometerData)
            }
        }
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

