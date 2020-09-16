

import UIKit

extension UIViewController{
    
    func showPermissionErrorAlertOnMainThread(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "Permission required.", preferredStyle: .alert)
            let okayButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                alert.dismiss(animated: true)
            })
            alert.addAction(okayButton)
            self.present(alert, animated: true)
        }
    }
}
