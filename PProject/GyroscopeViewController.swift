
import Foundation
import CoreMotion
import UIKit

class GyroscopeViewController: UIViewController{
    
    final let updateInterval = 1.0 / 60
    
    @IBOutlet weak var gyroscopeLabelX: UILabel!
    @IBOutlet weak var gyroscopeLabelY: UILabel!
    @IBOutlet weak var gyroscopeLabelZ: UILabel!
    
    @IBOutlet weak var accerlerometerLabelX: UILabel!
    @IBOutlet weak var accerlerometerLabelY: UILabel!
    @IBOutlet weak var accerlerometerLabelZ: UILabel!
    
    @IBOutlet weak var magnetometerLabelX: UILabel!
    @IBOutlet weak var magnetometerLabelY: UILabel!
    @IBOutlet weak var magnetometerLabelZ: UILabel!
    
    var motion = CMMotionManager()
    var timer: Timer?
    let activityManager = CMMotionActivityManager()
    override func viewDidLoad() {
        startGyros()
        startAccelerometer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopGyros()
    }
    
    func startAccelerometer(){
        print(motion.isAccelerometerAvailable)
        if motion.isAccelerometerAvailable{
            self.motion.accelerometerUpdateInterval = updateInterval
            self.motion.startAccelerometerUpdates()
            self.timer = Timer(fire: Date(), interval: (updateInterval),
                   repeats: true, block: { (timer) in
               if let data = self.motion.accelerometerData {
                  let x = data.acceleration.x
                  let y = data.acceleration.y
                  let z = data.acceleration.z
                  self.accerlerometerLabelX.text = String(format: "%.6f", x)
                  self.accerlerometerLabelY.text = String(format: "%.6f", y)
                  self.accerlerometerLabelZ.text = String(format: "%.6f", z)
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
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z
                self.gyroscopeLabelX.text = String(format: "%.8d", x)
                self.gyroscopeLabelY.text = String(format: "%.8d", y)
                self.gyroscopeLabelZ.text = String(format: "%.8d", z)
             }
          })
        RunLoop.current.add(self.timer!, forMode: .default)
       }
    }

    func stopGyros() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil
          self.motion.stopGyroUpdates()
       }
    }
}
