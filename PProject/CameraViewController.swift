
import UIKit
import AVFoundation

class CameraViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    var session: AVCaptureSession?
    var sessionActive = false
    var captureViewLayer: AVCaptureVideoPreviewLayer!
    var imagesTaken = [UIImage]()
    
    @IBOutlet weak var preview: UIView!
    
    var skipCounter = 0
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let imageCollectionViewProvider = ImageCollectionViewProvider()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        checkPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureViewLayer?.frame = preview.frame
    }
    
    func checkPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            self.sessionActive = true
            setupSession()
        }else{
            print("not authorized")
        }
    }
    
    func setupCollectionView() {
        imageCollectionView.dataSource = imageCollectionViewProvider
        imageCollectionView.delegate = imageCollectionViewProvider
        imageCollectionView.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "secretImageCell")
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
        captureViewLayer.isHidden.toggle()
    }
    
    func setupSession() {
        session = AVCaptureSession()
        guard let session = session else { return }
        guard let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            session.beginConfiguration()
            session.addInput(input)
            let output = AVCaptureVideoDataOutput()
            session.addOutput(output)
            session.commitConfiguration()
            let queue = DispatchQueue(label: "bufferOutput.queue")
            output.setSampleBufferDelegate(self, queue: queue)
        } catch {
            print("error setting up session")
        }
        session.startRunning()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
        
        self.skipCounter += 1
            if self.skipCounter % 50 == 0 {
                DispatchQueue.main.async {
                    self.imageCollectionViewProvider.images.append(UIImage(ciImage: ciImage.oriented(forExifOrientation: 6)))
                    self.imageCollectionView.reloadData()
                    self.imageCollectionView.scrollToLast()
                    print(self.imageCollectionViewProvider.images.count)
                }
            }
        }
    }
        
    


