
import UIKit
import AVFoundation


protocol FrontCameraDelegate: class{
    func frontPictureTaken(image: CIImage)
    func finishFrontSession()
}

protocol BackCameraDelegate: class{
    func backPictureTaken(image: CIImage)
    func finishBackSession()
}

enum CaptureState{
    case frontCameraActive
    case backCameraActive
    case inactive
}


class CameraViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, FrontCameraDelegate, BackCameraDelegate{
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backCameraLabel: UILabel!
    @IBOutlet weak var frontCameraLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var frontCamerasession: AVCaptureSession?
    var backCameraSession: AVCaptureSession?
    var frontCameraSampleBufferDelegate = FrontCameraSampleBufferDelegate()
    var backCameraSampleBufferDelegate = BackCameraSampleBufferDelegate()
    
    var grantPermissionButton:UIButton?
    var startButton:UIButton?
    
    var coverView = UIView()
    
    @IBOutlet weak var imagesTakenLabel: UILabel!
    
    @IBOutlet weak var backCameraCollectionView: UICollectionView!
    @IBOutlet weak var frontCameraCollectionView: UICollectionView!
    
    let imageCollectionViewProvider = ImageCollectionViewProvider()
    let backImageCollectionProvider = BackImageCollectionViewProvider()
    
    var captureState = CaptureState.inactive{
        didSet {
            updateStatusLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCoverView()
        updateStatusLabel()
        setupCollectionView()
        frontCameraSampleBufferDelegate.frontDelegate = self
        backCameraSampleBufferDelegate.backDelegate = self
        showActionButton()
    }
    
    fileprivate func configureCoverView(){
        self.view.addSubview(coverView)
        coverView.pinToEdges(of: self.view)
        coverView.backgroundColor = .white
    }
    
    fileprivate func showActionButton() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            showStartButton()
        }else{
            showPermissionButton()
        }
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
    
    @objc func grantPermissionButtonPressed(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            present(imagePicker,animated: true, completion: nil)
        }
        grantPermissionButton?.removeFromSuperview()
        showStartButton()
    }
    
    @objc func startButtonPressed(){
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            startButton?.removeFromSuperview()
            coverView.removeFromSuperview()
            setupBackCameraSession()
        }
    }
    
    func updateStatusLabel(){
        DispatchQueue.main.async {
            self.statusLabel.text = self.getStatus()
        }
    }
    
    func getStatus()->String{
        var labelString = "Status: "
        switch(self.captureState){
        case .frontCameraActive:
            labelString.append(contentsOf: "Front camera active")
        case .backCameraActive:
            labelString.append(contentsOf: "Back camera active")
        case .inactive:
            labelString.append(contentsOf: "Frontkamera aktiv")
        }
        return labelString
    }
    
    func frontPictureTaken(image: CIImage) {
        self.imageCollectionViewProvider.images.append(UIImage(ciImage: image.oriented(forExifOrientation: 6)))
        DispatchQueue.main.async {
            self.frontCameraCollectionView.reloadData()
            self.frontCameraCollectionView.scrollToLastItem()
            self.updateLabel()
        }
    }
    
    func backPictureTaken(image: CIImage) {
        self.backImageCollectionProvider.images.append(UIImage(ciImage: image.oriented(forExifOrientation: 6)))
        DispatchQueue.main.async {
            self.backCameraCollectionView.reloadData()
            self.backCameraCollectionView.scrollToLastItem()
            self.updateLabel()
        }
    }

    func updateLabel(){
        self.imagesTakenLabel.text = "Photos taken: \(self.imageCollectionViewProvider.images.count + self.backImageCollectionProvider.images.count)"
    }
    
    func finishFrontSession() {
        self.captureState = .inactive
        self.frontCamerasession = nil
    }
    
    func finishBackSession() {
        self.captureState = .inactive
        self.backCameraSession = nil
        setupSessionFrontCamera()
    }
    
    
    func setupCollectionView() {
        frontCameraCollectionView.dataSource = imageCollectionViewProvider
        frontCameraCollectionView.delegate = imageCollectionViewProvider
        frontCameraCollectionView.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "secretImageCell")
        
        backCameraCollectionView.dataSource = backImageCollectionProvider
        backCameraCollectionView.delegate = backImageCollectionProvider
        backCameraCollectionView.register(UINib.init(nibName: "BackImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "backSecretImageCell")
    }
    
    @IBAction func grantPermissionButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            present(imagePicker,animated: true, completion: nil)
        }
    }
    
    func setupSessionFrontCamera() {
        frontCamerasession = AVCaptureSession()
        guard let frontCamerasession = frontCamerasession else { return }
        guard let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { return }
        self.captureState = .frontCameraActive
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            frontCamerasession.beginConfiguration()
            frontCamerasession.addInput(input)
            let output = AVCaptureVideoDataOutput()
            frontCamerasession.addOutput(output)
            frontCamerasession.commitConfiguration()
            let queue = DispatchQueue(label: "frontBufferOutput.queue")
            output.setSampleBufferDelegate(frontCameraSampleBufferDelegate, queue: queue)
        } catch {
            print("error setting up session")
        }
        frontCamerasession.startRunning()
    }
    
    func setupBackCameraSession() {
        backCameraSession = AVCaptureSession()
        guard let backCameraSession = backCameraSession else { return }
        guard let camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { return }
        self.captureState = .backCameraActive
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            backCameraSession.beginConfiguration()
            backCameraSession.addInput(input)
            let output = AVCaptureVideoDataOutput()
            backCameraSession.addOutput(output)
            
            backCameraSession.commitConfiguration()
            let queue = DispatchQueue(label: "backBufferOutput.queue")
            output.setSampleBufferDelegate(backCameraSampleBufferDelegate, queue: queue)
        } catch {
            print("error setting up session")
        }
        backCameraSession.startRunning()
    }
}


class FrontCameraSampleBufferDelegate: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var frontDelegate: FrontCameraDelegate?
    var skipFrameCount = 0
    var pictureCount = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
        
        self.skipFrameCount += 1
        if self.skipFrameCount % 30 == 0 {
            if(pictureCount >= 10){
                frontDelegate?.finishFrontSession()
            }
            else{
                frontDelegate?.frontPictureTaken(image: ciImage)
                pictureCount += 1
            }
            
        }
    }
}

class BackCameraSampleBufferDelegate: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var backDelegate: BackCameraDelegate?
    var skipFrameCount = 0
    var pictureCount = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
        skipFrameCount += 1
        if skipFrameCount % 30 == 0 {
            if(pictureCount >= 10){
                backDelegate?.finishBackSession()
            }else{
                backDelegate?.backPictureTaken(image: ciImage)
                pictureCount += 1
            }
            
        }
    }
}



