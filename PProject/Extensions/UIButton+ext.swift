import UIKit


extension UIButton{
    
    func makeActionButton(title: String){
        self.setTitle(title, for: .normal)
        self.titleLabel?.lineBreakMode = .byCharWrapping
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 6
        self.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        self.titleEdgeInsets = UIEdgeInsets(top: -10,left: -10,bottom: -10,right: -10)
        self.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
    }
    
}

