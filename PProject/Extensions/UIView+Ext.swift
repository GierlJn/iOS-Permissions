

import UIKit

extension UIView{
    

    func centerInSuperView(superView: UIView){
        let centerYAnchorConstraint = self.centerYAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerYAnchor)
        let margins = superView.layoutMarginsGuide
        let centerXAnchorConstraint = self.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
        centerYAnchorConstraint.isActive = true
        centerXAnchorConstraint.isActive = true
    }
    
}
