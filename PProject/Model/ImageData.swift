
import Foundation
import Photos
import MapKit


class ImageData{
    
    var phAsset: PHAsset
    
    var image: UIImage?
    
    var model: String?
    var software: String?
    var manufacturer: String?
    
    var lensModel: String?
    var lensManufcaturer: String?
    var width: Int?
    var height: Int?
    
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var direction: Double?
    var speed: Double?
    
    init(phAsset: PHAsset){
        self.phAsset = phAsset
    }
    
    func loadDetails(completion: @escaping()->()){
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        self.phAsset.requestContentEditingInput(with: options, completionHandler: { contentEditingInput, info in
            let imageURL = contentEditingInput?.fullSizeImageURL
            if imageURL == nil {
                return
            }
            
            let imageSource = CGImageSourceCreateWithURL(imageURL! as CFURL, nil)
            guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as? [CFString: Any] else{
                print("not possible")
                return
            }
            
            var dpi : Int? { imageProperties[kCGImagePropertyDPIWidth] as? Int }
            var width : Int? { imageProperties[kCGImagePropertyPixelWidth] as? Int }
            var height : Int? { imageProperties[kCGImagePropertyPixelHeight] as? Int }
            var tiff : [CFString: Any]? { imageProperties[kCGImagePropertyTIFFDictionary] as? [CFString: Any] }
            var exif: [CFString: Any]? { imageProperties[kCGImagePropertyExifDictionary] as? [CFString: Any] }
            var gps:[CFString: Any]? { imageProperties[kCGImagePropertyGPSDictionary] as? [CFString: Any] }
            
            if(tiff != nil){
                self.model = tiff![kCGImagePropertyTIFFModel] as? String
                self.software = tiff![kCGImagePropertyTIFFSoftware] as? String
                self.manufacturer = tiff![kCGImagePropertyTIFFMake] as? String
            }
            if(exif != nil){
                self.lensModel = exif![kCGImagePropertyExifLensModel] as? String
                self.lensManufcaturer = exif![kCGImagePropertyExifLensMake] as? String
                self.width = imageProperties[kCGImagePropertyPixelWidth] as? Int
                self.height = imageProperties[kCGImagePropertyPixelHeight] as? Int
            }
            
            if(gps != nil){
                self.latitude = gps![kCGImagePropertyGPSLatitude] as? Double
                self.longitude = gps![kCGImagePropertyGPSLongitude] as? Double
                self.altitude = gps![kCGImagePropertyGPSAltitude] as? Double
                self.direction = gps![kCGImagePropertyGPSImgDirection] as? Double
                self.speed = gps![kCGImagePropertyGPSSpeed] as? Double
            }
            completion()
        })
    }
    
    
    func loadImage(){
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        self.phAsset.requestContentEditingInput(with: options, completionHandler: { contentEditingInput, info in
            guard let url = contentEditingInput?.fullSizeImageURL else { return }
            var imageData: Data?
            do{
                try imageData = Data(contentsOf: url)
            }catch{
                print(error)
            }
            
            guard let image = UIImage(data: imageData!) else { return }
            self.image = image
        })
    }
}





