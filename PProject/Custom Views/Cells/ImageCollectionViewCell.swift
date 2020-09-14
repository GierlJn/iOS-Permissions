
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    static let reuseIdentifier = "secretImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
