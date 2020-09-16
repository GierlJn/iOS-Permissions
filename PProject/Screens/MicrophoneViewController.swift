
import Foundation
import UIKit
import AVFoundation

class MicrophoneViewController: UIViewController, AVAudioRecorderDelegate{
    
    var grantPermissionButton:UIButton?
    var startButton:UIButton?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    var counter = 0.0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !checkPermission(){
            self.showPermissionButton()
        }else{
            self.showStartButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statusLabel.text = "Microphone not active"
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
        counter = 0.0
        timeLabel.text = String(counter)
    }
    
    @objc func updateTimer() {
        counter = counter + 0.1
        timeLabel.text = String(format: "%.1f", counter)
    }
    
    func checkPermission() -> Bool {

        var permissionCheck: Bool = false

        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            permissionCheck = true
        case AVAudioSessionRecordPermission.denied:
            permissionCheck = false
        case AVAudioSessionRecordPermission.undetermined:
            permissionCheck = false
        default:
            break
        }

        return permissionCheck
    }
    
    @objc func startButtonPressed() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func grantPermissionButtonPressed() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.grantPermissionButton?.isHidden = true
                        self.grantPermissionButton?.removeFromSuperview()
                        self.showStartButton()
                    } else {
                        self.showPermissionErrorAlertOnMainThread()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            startTimer()
            startButton!.setTitle("Stop", for: .normal)
            statusLabel.text = "Microphone active"
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        stopTimer()
        statusLabel.text = "Microphone not active"
        if success {
            startButton!.setTitle("Restart", for: .normal)
        } else {
            startButton!.setTitle("Start", for: .normal)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    fileprivate func showStartButton() {
        startButton = UIButton(type: .roundedRect)
        startButton!.makeActionButton(title: "Start", view: self.view)
        startButton!.addTarget(self, action: #selector(self.startButtonPressed), for: .touchUpInside)
    }
    
    fileprivate func showPermissionButton() {
        grantPermissionButton = UIButton(type: .roundedRect)
        grantPermissionButton!.makeActionButton(title: "Grant \n permission", view: self.view)
        grantPermissionButton!.addTarget(self, action: #selector(self.grantPermissionButtonPressed), for: .touchUpInside)
    }
}
