
import Foundation
import UIKit
import AVFoundation

class MicrophoneViewController: UIViewController, AVAudioRecorderDelegate{
    
    var grantPermissionButton:UIButton?
    var startButton:UIButton?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

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
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
        counter = 0.0
        statusLabel.text = String(counter)
    }
    
    @objc func updateTimer() {
        counter = counter + 0.1
        statusLabel.text = String(format: "%.1f", counter)
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
                        DispatchQueue.main.async {
                        let alert = UIAlertController(title: "", message: "Berechtigung für Mikrofon wird benötigt.", preferredStyle: .alert)
                        let okayButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                            alert.dismiss(animated: true)
                        })
                        alert.addAction(okayButton)
                        self.present(alert, animated: true)
                        }
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("aufnahme.m4a")

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
            startButton!.setTitle("Aufnahme beenden", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        stopTimer()
        if success {
            startButton!.setTitle("Aufnahme Neustarten", for: .normal)
        } else {
            startButton!.setTitle("Aufnahme Starten", for: .normal)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    fileprivate func showStartButton() {
        startButton = UIButton(type: .roundedRect)
        startButton!.makeActionButton(title: "Aufnahme \n starten")
        startButton!.addTarget(self, action: Selector(("startButtonPressed")), for: .touchUpInside)
        self.view.addSubview(startButton!)
        startButton!.translatesAutoresizingMaskIntoConstraints = false
        let centerYAnchorConstraint = startButton!.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        let margins = view.layoutMarginsGuide
        let centerXAnchorConstraint = startButton!.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
        centerYAnchorConstraint.isActive = true
        centerXAnchorConstraint.isActive = true
    }
    
    fileprivate func showPermissionButton() {
        grantPermissionButton = UIButton(type: .roundedRect)
        grantPermissionButton!.makeActionButton(title: "Zugriff \n erlauben")
        grantPermissionButton!.addTarget(self, action: Selector(("grantPermissionButtonPressed")), for: .touchUpInside)
        self.view.addSubview(grantPermissionButton!)
        grantPermissionButton!.translatesAutoresizingMaskIntoConstraints = false
        let centerYAnchorConstraint = grantPermissionButton!.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        let margins = view.layoutMarginsGuide
        let centerXAnchorConstraint = grantPermissionButton!.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
        centerYAnchorConstraint.isActive = true
        centerXAnchorConstraint.isActive = true
    }
}
