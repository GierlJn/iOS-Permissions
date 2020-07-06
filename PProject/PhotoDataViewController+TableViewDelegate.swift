import UIKit
import Foundation

extension PhotoDataViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selectedImage == nil){
            return 0
        }
        switch(section){
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return 2
        case 3:
            return 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "Foto"
        case 1:
            return "Gerät"
        case 2:
            return "Objektiv"
        case 3:
            return "GPS Daten"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetaDataCell", for: indexPath) as! MetaDataTableViewCell
        guard let selectedImage = selectedImage else {
            return cell
        }
        
        switch(indexPath.section){
        case 0:
            switch(indexPath.row){
            case 0:
                cell.configureCell(keyLabel: "Datum", valueLabel: formatter.string(from: (selectedImage.phAsset.creationDate)!))
            case 1:
                cell.configureCell(keyLabel: "Auflösung", valueLabel: "\(selectedImage.width ?? 0) x \(selectedImage.height ?? 0)")
            default:
                return cell
            }
        case 1:
            switch(indexPath.row){
            case 0:
                cell.configureCell(keyLabel: "Gerät", valueLabel: selectedImage.model)
            case 1:
                cell.configureCell(keyLabel: "Hersteller", valueLabel: selectedImage.manufacturer)
            case 2:
                cell.configureCell(keyLabel: "Software", valueLabel: selectedImage.software)
            default:
                return cell
            }
        case 2:
            switch(indexPath.row){
            case 0:
                cell.configureCell(keyLabel: "Name", valueLabel: selectedImage.lensModel)
            case 1:
                cell.configureCell(keyLabel: "Hersteller", valueLabel: selectedImage.lensManufcaturer)
            default:
                return cell
            }
        case 3:
            switch(indexPath.row){
            case 0:
                cell.configureCell(keyLabel: "Breitengrad", valueLabel: String(format: "%.3f°", selectedImage.latitude ?? 0))
            case 1:
                cell.configureCell(keyLabel: "Längengrad", valueLabel: String(format: "%.3f°", selectedImage.longitude ?? 0))
            case 2:
                cell.configureCell(keyLabel: "Höhe", valueLabel: String(format: "%.3fm", selectedImage.altitude ?? 0))
            case 3:
                cell.configureCell(keyLabel: "Kamera Richtung", valueLabel: String(format: "%.3f°", selectedImage.direction ?? 0))
            case 4:
                cell.configureCell(keyLabel: "Geschwindigkeit", valueLabel: String(format: "%.2f km/h", selectedImage.phAsset.location?.speed ?? 0 * 3.6)) //m/s to km/
            default:
                return cell
            }
        default:
            return cell
        }
        return cell
    }
}
