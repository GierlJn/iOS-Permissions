
import Foundation
import MapKit
import UIKit
import Photos

final class MapAnnotation: NSObject, MKAnnotation{
    let coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var title: String?
    var id: Int
    
    init(id: Int, locationData: ImageData){
        self.id = id
        self.coordinate = (locationData.phAsset.location!.coordinate)
        self.image = locationData.image
    }
}

class MetaDataVC: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedImage: ImageData?
    var images = [ImageData]()
    var mapAnnotations: [MapAnnotation]?
    
    var grantPermissionButton:UIButton?
    var startButton:UIButton?
    var infoLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let auth = PHPhotoLibrary.authorizationStatus()
        if auth == .authorized {
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
    
    fileprivate func showInfoLabel(){
        infoLabel = UILabel()
        infoLabel!.lineBreakMode = .byWordWrapping
        infoLabel!.text = String(format: "%lu photos / videos were found.", UInt(self.images.count))
        infoLabel?.textAlignment = .center
        self.view.addSubview(infoLabel!)
        infoLabel!.translatesAutoresizingMaskIntoConstraints = false
        infoLabel!.centerInSuperView(superView: self.view)
        
    }
    
    fileprivate func showPermissionButton() {
        grantPermissionButton = UIButton(type: .roundedRect)
        grantPermissionButton!.makeActionButton(title: "Grant \n permission", view: self.view)
        grantPermissionButton!.addTarget(self, action: #selector(self.grantPermissionButtonPressed), for: .touchUpInside)
    }
    
    @objc func grantPermissionButtonPressed(){
        PHPhotoLibrary.requestAuthorization({ auth in
            if auth == .authorized {
                DispatchQueue.main.async {
                    self.grantPermissionButton?.isHidden = true
                    self.grantPermissionButton?.removeFromSuperview()
                    self.showStartButton()
                }
                
            } else if auth == .denied {
                self.showPermissionErrorAlertOnMainThread()
            }
        })
    }
    
    @objc func startButtonPressed(){
        let auth = PHPhotoLibrary.authorizationStatus()
        if auth == .authorized {
            startButton?.isHidden = true
            startButton?.removeFromSuperview()
            self.fetchPhotos()
            self.setupAnnotations()
        }
    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "MetaDataTableViewCell", bundle: nil), forCellReuseIdentifier: "MetaDataCell")
    }
    
    
    private func fetchPhotos() {
        let options = PHFetchOptions()
        options.includeHiddenAssets = true
        var locations = [ImageData]()
        let photos = PHAsset.fetchAssets(with: .image, options: options)
        for index in 0..<photos.count{
            let photo = photos[index]
            if photo.location != nil {
                let imageData = ImageData(phAsset: photo)
                locations.append(imageData)
            }
        }
        self.images = locations
    }
    
    private func setupAnnotations() {
        DispatchQueue.main.async{
            self.mapAnnotations = [MapAnnotation]()
            for i in 0..<self.images.count {
                let imageData = self.images[i]
                let annotation = MapAnnotation(id: i, locationData: imageData)
                self.mapAnnotations!.append(annotation)
            }
            self.mapView?.addAnnotations(self.mapAnnotations!)
            self.showInfoLabel()
        }
    }
    
}

extension MetaDataVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = self.mapView?.selectedAnnotations.first as? MapAnnotation
        let image = images[selectedAnnotation!.id]
        selectedImage = image
        selectedImage?.loadDetails {
            self.tableView.isHidden = false
            self.infoLabel?.isHidden = true
            self.infoLabel?.removeFromSuperview()
            self.tableView.reloadData()
        }
    }
}
