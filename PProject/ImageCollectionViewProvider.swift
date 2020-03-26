

import Foundation
import UIKit


class ImageCollectionViewProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var images = [UIImage]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "secretImageCell", for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView.image = image
        cell.imageView.contentMode = .scaleToFill
        return cell
    }
}

class BackImageCollectionViewProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var images = [UIImage]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backSecretImageCell", for: indexPath) as! BackImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView.image = image
        cell.imageView.contentMode = .scaleToFill
        return cell
    }
}

extension UICollectionView {
    func scrollNext() {
        
        let offset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.scrollFrame(offset: offset)
    }
    
    func scrollFrame(offset : CGFloat) {
        guard offset <= self.contentSize.width - self.bounds.size.width else {
            print(offset)
            return }
        guard offset >= 0 else { return }
        print("moved")
        self.setContentOffset(CGPoint(x: offset, y: self.contentOffset.y), animated: true)
    }
}

extension UICollectionView {
    func scrollToLast() {

        let lastSection = 0

        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }

        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .right, animated: true)
    }
}
