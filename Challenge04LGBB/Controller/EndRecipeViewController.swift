//
//  EndRecipe.swift
//  Challenge04LGBB
//
//  Created by Luciano Uchoa on 26/08/22.
//

import Foundation
import UIKit
import AVFoundation
import PhotosUI

class EndRecipeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageMedalha: UIImageView!
    @IBOutlet weak var medalhaView: UIView!
    @IBOutlet weak var labelDesbloqueio: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imagePlaceholder: UIView!
    @IBOutlet weak var imageTake: UIImageView!
    var imagePicker: UIImagePickerController!
    var indexReceitaEscolhida = 0
    var haptic = false
    
    let confetti = showConfetti()
    
    enum imageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBackButton()
        setupLabel()
        imageTake.layer.cornerRadius = 10
        let defaults = UserDefaults.standard
        haptic = defaults.bool(forConfigKey: .haptic)
    }
    
    func setupNavigationBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func ShareButton(_ sender: Any) {
        navigation(Destino: .modelo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        confetti.emit(in: view, with: .fromTopLeft)
        confetti.emit(in: view, with: .fromTopRight)
        
        imagePlaceholder.layer.cornerRadius = 10
        AppDelegate.AppUtility.lockOrientation(.allButUpsideDown)
    }
    
    func navigation(Destino:Destinations){
        if(Destino == .listRecipes){
            let storyBoard: UIStoryboard = UIStoryboard(name: Destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.listRecipes.rawValue) as! ListRecipesViewController
            
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        if(Destino == .modelo){
            let storyBoard: UIStoryboard = UIStoryboard(name: Destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.modelo.rawValue) as! TemplateScreen
            newViewController.image = imageTake.image
            newViewController.escolha = indexReceitaEscolhida
            
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }
    }
    
    func setupLabel(){
        let receitas = getRecipes()
        imageMedalha.image = receitas[indexReceitaEscolhida].medalha
        labelDesbloqueio.text = receitas[indexReceitaEscolhida].tituloReceita.localize()
        imageMedalha.isAccessibilityElement = true
        imageMedalha.accessibilityLabel = "Imagem da medalha ganha por terminar a receita!"
        cameraButton.layer.cornerRadius = 10
    }
    
 
    @IBAction func backToRecipeScrenn(_ sender: Any) {
        navigation(Destino: .listRecipes)
    }
    
    
    //MARK: - Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                DispatchQueue.main.async {
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        self.selectImageFrom(.photoLibrary)
                        return
                    }
                    self.selectImageFrom(.camera)
                    if self.haptic == true {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                    }
                }
            }else {
                DispatchQueue.main.async { [unowned self] in
                    let alertController = UIAlertController(title: "Permissão Necessária".localize(), message: "Para ter acesso a camera, é necessário habilitar a permissão nos Ajustes".localize(), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ajustes".localize(), style: .cancel) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:] , completionHandler: {
                                _ in
                            })
                        }
                    })
                    alertController.addAction(UIAlertAction(title: "Cancelar".localize(), style: .default))
                    
                    
                    present(alertController, animated: true)
                }
            }
        }
    }
    
    func selectImageFrom(_ source: imageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imageTake.sizeToFit()
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Saving Image here
    func save(_ sender: AnyObject) {
        guard let selectedImage = imageTake.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        imageTake.isHidden = false
        cameraButton.isHidden = true
        imagePlaceholder.isHidden = true
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { response in
            if response == PHAuthorizationStatus.denied{
                DispatchQueue.main.async { [unowned self] in
                    let alertController = UIAlertController(title: "Permissão Necessária".localize(), message: "Para salvar as fotos, é necessário habilitar a permissão nos Ajustes".localize(), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ajustes".localize(), style: .cancel) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:] , completionHandler: {
                                _ in
                            })
                        }
                    })
                    alertController.addAction(UIAlertAction(title: "Cancelar".localize(), style: .default))
                    
                    
                    present(alertController, animated: true)
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard var selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        selectedImage = selectedImage.withRoundedCorners(radius: 100)!
        imageTake.image = selectedImage
        save(self)
    }
    
    @IBAction func sharePhoto(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: medalhaView.bounds.size)
        let image2 = renderer.image { ctx in
            medalhaView.drawHierarchy(in: medalhaView.bounds, afterScreenUpdates: true)
        }
        
        let imageToShare = [ image2, imageTake ]
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


