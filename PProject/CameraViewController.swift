
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

    
    
    @IBOutlet weak var permissionLabel: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var frontCamerasession: AVCaptureSession?
    var backCameraSession: AVCaptureSession?
    var imagesTaken = [UIImage]()
    var frontCameraSampleBufferDelegate = FrontCameraSampleBufferDelegate()
    var backCameraSampleBufferDelegate = BackCameraSampleBufferDelegate()
    
    var captureState = CaptureState.inactive{
        didSet {
            updateStatusLabel()
        }
    }
    @IBOutlet weak var backCameraCollectionView: UICollectionView!
    @IBOutlet weak var frontCameraCollectionView: UICollectionView!
    
    let imageCollectionViewProvider = ImageCollectionViewProvider()
    let backImageCollectionProvider = BackImageCollectionViewProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateStatusLabel()
        setupCollectionView()
        checkPermission()
        frontCameraSampleBufferDelegate.frontDelegate = self
        backCameraSampleBufferDelegate.backDelegate = self
    }
    
    func updateStatusLabel(){
        DispatchQueue.main.async {
            self.statusLabel.text = self.getStatus()
        }
    }
    
    func updatePermissionLabel(){
        DispatchQueue.main.async {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authStatus == .authorized {
                self.permissionLabel.titleLabel!.text = "Permission was granted"
                self.permissionLabel.isUserInteractionEnabled = false
            }else{
                self.permissionLabel.titleLabel!.text = "Grant Permission"
                self.permissionLabel.isUserInteractionEnabled = true
            }
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
            labelString.append(contentsOf: "No camera active")
        }
        return labelString
        
    }
    
    func frontPictureTaken(image: CIImage) {
        self.imageCollectionViewProvider.images.append(UIImage(ciImage: image.oriented(forExifOrientation: 6)))
        DispatchQueue.main.async {
            self.frontCameraCollectionView.reloadData()
            self.frontCameraCollectionView.scrollToLast()
            print(self.imageCollectionViewProvider.images.count)
        }
    }
    
    func backPictureTaken(image: CIImage) {
        self.backImageCollectionProvider.images.append(UIImage(ciImage: image.oriented(forExifOrientation: 6)))
        DispatchQueue.main.async {
            self.backCameraCollectionView.reloadData()
            self.backCameraCollectionView.scrollToLast()
            print(self.backImageCollectionProvider.images.count)
        }
    }
    
    func checkPermission() {
        self.updatePermissionLabel()
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            setupBackCameraSession()
        }else{
            print("not authorized")
        }
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
        guard let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { return }
        self.captureState = .backCameraActive
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
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
    var skipCounter = 0
    var takenPictures = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
    let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
    
    self.skipCounter += 1
        if self.skipCounter % 30 == 0 {
            if(takenPictures >= 10){
                frontDelegate?.finishFrontSession()
            }
            else{
                frontDelegate?.frontPictureTaken(image: ciImage)
                takenPictures += 1
            }
            
        }
    }
}

class BackCameraSampleBufferDelegate: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var backDelegate: BackCameraDelegate?
    var skipCounter = 0
    var takenPictures = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
    let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
    
    skipCounter += 1
        if skipCounter % 30 == 0 {
            if(takenPictures >= 10){
                backDelegate?.finishBackSession()
            }else{
                backDelegate?.backPictureTaken(image: ciImage)
                takenPictures += 1
            }
            
        }
    }
}
    


