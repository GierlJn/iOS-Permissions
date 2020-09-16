import UIKit


extension UIButton{
    
    func makeActionButton(title: String, view: UIView){
        self.setTitle(title, for: .normal)
        self.titleLabel?.lineBreakMode = .byCharWrapping
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 6
        self.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        self.titleEdgeInsets = UIEdgeInsets(top: -10,left: -10,bottom: -10,right: -10)
        self.contentEdgeInsets = UIEdgeInsets(top: 15,left: 15,bottom: 15,right: 15)
        
        view.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
          let centerYAnchorConstraint = self.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
          let margins = view.layoutMarginsGuide
          let centerXAnchorConstraint = self.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
          centerYAnchorConstraint.isActive = true
          centerXAnchorConstraint.isActive = true
    }
    
}

