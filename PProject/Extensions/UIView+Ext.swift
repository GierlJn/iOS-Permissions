

import UIKit

extension UIView{

    func centerInSuperView(superView: UIView){
        let centerYAnchorConstraint = self.centerYAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerYAnchor)
        let margins = superView.layoutMarginsGuide
        let centerXAnchorConstraint = self.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
        centerYAnchorConstraint.isActive = true
        centerXAnchorConstraint.isActive = true
    }
    
     func pinToEdges(of superview: UIView){
           translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               topAnchor.constraint(equalTo: superview.topAnchor),
               leadingAnchor.constraint(equalTo: superview.leadingAnchor),
               trailingAnchor.constraint(equalTo: superview.trailingAnchor),
               bottomAnchor.constraint(equalTo: superview.bottomAnchor)
           ])
    }

}
