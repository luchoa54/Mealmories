import Foundation
import UIKit

class TemplateScreen: UIViewController {
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var imagemMedalha: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    var escolha : Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.layer.cornerRadius = 10
        let receitas = getChosenRecipe()
        let medalha = getRecipes()
        imagemMedalha.image = medalha[escolha].imagemShare
        photo.image = image
        Name.text = medalha[escolha].tituloReceita.localize()
        if photo.image == nil {
            photo.image = receitas[escolha].imagemReceita
        }
        
    }
    
    
    @IBAction func Share(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: shareView.bounds.size)
        let image2 = renderer.image { ctx in
            shareView.drawHierarchy(in: shareView.bounds, afterScreenUpdates: true)
        }
        
        
        let imageToShare = [ image2 ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
        
        
        if let popoverController = activityViewController.popoverPresentationController{
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
    }
}
