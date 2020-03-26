
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

class CameraViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, FrontCameraDelegate, BackCameraDelegate{

    
    let imagePicker = UIImagePickerController()
    var frontCamerasession: AVCaptureSession?
    var backCameraSession: AVCaptureSession?
    var sessionActive = false
    var captureViewLayer: AVCaptureVideoPreviewLayer!
    var imagesTaken = [UIImage]()
    var frontCameraSampleBufferDelegate = FrontCameraSampleBufferDelegate()
    var backCameraSampleBufferDelegate = BackCameraSampleBufferDelegate()
    //@IBOutlet weak var preview: UIView!
    
    @IBOutlet weak var backCameraCollectionView: UICollectionView!
    @IBOutlet weak var frontCameraCollectionView: UICollectionView!
    
    let imageCollectionViewProvider = ImageCollectionViewProvider()
    let backImageCollectionProvider = BackImageCollectionViewProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        checkPermission()
        frontCameraSampleBufferDelegate.frontDelegate = self
        backCameraSampleBufferDelegate.backDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //captureViewLayer?.frame = preview.frame
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
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            self.sessionActive = true
            setupBackCameraSession()
        }else{
            print("not authorized")
        }
    }
    
    func finishFrontSession() {
        if(self.sessionActive){
            self.frontCamerasession = nil
            self.sessionActive = false
        }
    }
    
    func finishBackSession() {
        if(self.sessionActive){
            self.backCameraSession = nil
            setupSessionFrontCamera()
        }
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
    
    @IBAction func togglePreviewButtonTapped(_ sender: Any) {
        //captureViewLayer.isHidden.toggle()
    }
    
    func setupSessionFrontCamera() {
        frontCamerasession = AVCaptureSession()
        guard let frontCamerasession = frontCamerasession else { return }
        guard let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { return }
        
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
    


