
import Foundation
import MapKit
import UIKit
import Photos

fileprivate enum AppState{
    case permissionNotGiven
    case permissionGiven
    case dataIsLoaded
}

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

class PhotoDataViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var permissionButton: UIButton!
    
    var selectedImage: ImageData?
    var images = [ImageData]()
    var mapAnnotations: [MapAnnotation]?
    
    fileprivate var appState = AppState.permissionNotGiven{
        didSet{
            updateButtonLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        PHPhotoLibrary.requestAuthorization({ auth in
            if auth == .authorized {
                self.appState = AppState.permissionGiven
            } else if auth == .denied {
                let alert = UIAlertController(title: "", message: "Berechtigung wird benötigt um Daten aus den Fotos zu laden.", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    alert.dismiss(animated: true)
                })
                alert.addAction(okayButton)
                self.present(alert, animated: true)
            }
        })
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "MetaDataTableViewCell", bundle: nil), forCellReuseIdentifier: "MetaDataCell")
    }
    
    private func updateButtonLabel(){
        DispatchQueue.main.async {
            switch(self.appState){
            case .dataIsLoaded:
                self.permissionButton.titleLabel?.text = String(format: "Daten aus %lu Bildern wurden geladen", UInt(self.images.count))
            case .permissionNotGiven:
                self.permissionButton.titleLabel?.text = "Berechtigung für Fotos erteilen"
            case .permissionGiven:
                self.permissionButton.titleLabel?.text = "Daten aus Fotos laden"
            }
        }
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
            self.appState = AppState.dataIsLoaded
        }
    }
    
    @IBAction func permissionButtonWasPressed(_ sender: Any) {
        if(appState == .permissionGiven){
            self.fetchPhotos()
            self.setupAnnotations()
        }
    }
}

extension PhotoDataViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = self.mapView?.selectedAnnotations.first as? MapAnnotation
        let image = images[selectedAnnotation!.id]
        selectedImage = image
        selectedImage?.loadDetails {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
