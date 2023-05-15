
import Foundation
import UIKit

class IsInitialUser : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
     
        if LandscapeManager.shared.isFirstLaunch {
            var newViewController = ViewController()
            newViewController = ViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: .none)
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated:true, completion:nil)
            
            
            LandscapeManager.shared.isFirstLaunch = true
        }
        else{
     
            LandscapeManager.shared.isFirstLaunch = true
            let storyBoard: UIStoryboard = UIStoryboard(name: Destinations.listRecipes.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.listRecipes.rawValue) as! ListRecipesViewController
            
            self.navigationController?.pushViewController(newViewController, animated: false)
            
        }
    }
    class LandscapeManager {
        static let shared = LandscapeManager()
        var isFirstLaunch: Bool {
            get {
                !UserDefaults.standard.bool(forKey: #function)
            } set {
                UserDefaults.standard.setValue(newValue, forKey: #function)
            }
        }
    }
}



