
import Foundation
import CoreMotion
import UIKit

class SensorsViewController: UIViewController{
    
    final let updateInterval = 1.0 / 60
    
    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var zValueLabe: UILabel!

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var sensorLabel: UILabel!
    
    @IBOutlet weak var sensorsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceMotionSegmentedControl: UISegmentedControl!
    
    var motion = CMMotionManager()
    
    var timer: Timer?
    
    private var selectedSensor: Sensor {
        return Sensor(rawValue: sensorsSegmentedControl.selectedSegmentIndex)!
    }
    
    private var selectedDeviceMotionSensor: DeviceMotionSensor {
        return DeviceMotionSensor(rawValue: deviceMotionSegmentedControl.selectedSegmentIndex)!
    }
    
    override func viewDidLoad() {
        showSensor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSensors()
    }
    
    @IBAction func selectedSensorValueChanged(_ sender: Any) {
        if(selectedSensor == .deviceMotion){
            deviceMotionSegmentedControl.isHidden = false
        }else{
            deviceMotionSegmentedControl.isHidden = true
        }
        updateUILabels()
        showSensor()
    }
    
    @IBAction func selectedDeviceMotionSensorValueChanged(_ sender: Any) {
        updateUILabels()
    }
    
    private func showSensor(){
        stopSensors()
        switch(selectedSensor){
        case .accelerator:
            startAccelerometer()
        case .gyro:
            startGyros()
        case .magnetoMeter:
            startMagnetometer()
        case .deviceMotion:
            startDeviceMotion()
        }
    }
    
    func startDeviceMotion(){
        if motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = updateInterval
            self.motion.startDeviceMotionUpdates()
            self.timer = Timer(fire: Date(), interval: (updateInterval),
                               repeats: true, block: { (timer) in
                                if let data = self.motion.deviceMotion {
                                    switch(self.selectedDeviceMotionSensor){
                                    case .attitude:
                                        self.updateValueLabels(x: data.attitude.roll, y: data.attitude.pitch, z: data.attitude.yaw)
                                    case .rotationRate:
                                        self.updateValueLabels(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                                    case .gravity:
                                        self.updateValueLabels(x: data.gravity.x, y: data.gravity.y, z: data.gravity.z)
                                    case .userAcceleration:
                                        self.updateValueLabels(x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)
                                    }
                                }
            })
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func startAccelerometer(){
        if motion.isAccelerometerAvailable{
            self.motion.accelerometerUpdateInterval = updateInterval
            self.motion.startAccelerometerUpdates()
            self.timer = Timer(fire: Date(), interval: (updateInterval),
                   repeats: true, block: { (timer) in
               if let data = self.motion.accelerometerData {
                self.updateValueLabels(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
               }
            })
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func startMagnetometer(){
        if motion.isMagnetometerAvailable{
            self.motion.magnetometerUpdateInterval = updateInterval
            self.motion.startMagnetometerUpdates()
            self.timer = Timer(fire: Date(), interval: (updateInterval),
                   repeats: true, block: { (timer) in
               if let data = self.motion.magnetometerData {
                self.updateValueLabels(x: data.magneticField.x, y: data.magneticField.y, z: data.magneticField.z)
               }
            })
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func startGyros() {
       if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = updateInterval
          self.motion.startGyroUpdates()
          self.timer = Timer(fire: Date(), interval: (updateInterval),
                 repeats: true, block: { (timer) in
             if let data = self.motion.gyroData {
                self.updateValueLabels(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
             }
          })
        RunLoop.current.add(self.timer!, forMode: .default)
       }
    }
    
    private func stopSensors(){
        stopGyros()
        stopAccelerometer()
        stopMagnetoMeter()
    }
    
    private func stopAccelerometer() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil
          self.motion.stopAccelerometerUpdates()
       }
    }

    private func stopGyros() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil
          self.motion.stopGyroUpdates()
       }
    }
    
    private func stopMagnetoMeter() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil
          self.motion.stopMagnetometerUpdates()
       }
    }
    
    private func stopDeviceMotionSensor() {
        if self.timer != nil {
           self.timer?.invalidate()
           self.timer = nil
           self.motion.stopDeviceMotionUpdates()
        }
    }
    
    private func updateValueLabels(x: Double, y: Double, z: Double){
        self.xValueLabel.text = String(format: "%.8f", x)
        self.yValueLabel.text = String(format: "%.8f", y)
        self.zValueLabe.text = String(format: "%.8f", z)
    }
    
    private func updateUILabels() {
        if(selectedSensor != .deviceMotion){
            sensorLabel.text = selectedSensor.getString()
        }else{
            sensorLabel.text = selectedDeviceMotionSensor.getString()
        }
        if(selectedSensor == .deviceMotion && selectedDeviceMotionSensor == .rotationRate){
            xLabel.text = "Roll"
            yLabel.text = "Pitch"
            zLabel.text = "Yaw"
        }else{
            xLabel.text = "X"
            yLabel.text = "Y"
            zLabel.text = "Z"
        }
    }
}

fileprivate enum Sensor: Int{
    case  accelerator, gyro, magnetoMeter, deviceMotion
    func getString()->String{
        switch(self){
        case .accelerator:
            return  "Beschleunigungssensor"
        case .gyro:
            return "Gyrosensor"
        case .magnetoMeter:
            return "Magnetometer"
        default:
            return "DeviceSensor"
        }
    }
}

fileprivate enum DeviceMotionSensor: Int{
    case  attitude, gravity, rotationRate, userAcceleration
    func getString()->String{
        switch(self){
        case .attitude:
            return "Attitude"
        case .gravity:
            return "Gravity"
        case .rotationRate:
            return "Rotation"
        case .userAcceleration:
            return "User Acceleration"
        }
    }
}
