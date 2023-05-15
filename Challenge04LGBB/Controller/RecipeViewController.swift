import Foundation
import UIKit
import ARKit
import AVFoundation
import PhotosUI
import SwiftUI



class RecipeViewController: UIViewController, ARSCNViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    //Progess Bar

    @IBOutlet weak var progressBar: UIProgressView!
    // Botoes da tela
    @IBOutlet weak var botaoVoltar: UIButton!
    @IBOutlet weak var botaoTerminarReceita: UIButton!
    @IBOutlet weak var botaoIr: UIButton!
    @IBOutlet weak var labelIntrucao: UILabel!
    @IBOutlet weak var imagemIntrucao: UIImageView!
    @IBOutlet weak var labelTurno: UILabel!
    @IBOutlet weak var labelImagem: UILabel!
    @IBOutlet weak var viewTurno: UIView!
    @IBOutlet weak var imagemTurno: UIImageView!
    @IBOutlet weak var corDoFundoDaTela: UIView!
    @IBOutlet weak var lampImage: UIImageView!
    @IBOutlet weak var labelDica: UILabel!
    // SceneView
    @IBOutlet weak var sceneView: ARSCNView!
    // Nome da receita na Navigation Bar
    @IBOutlet weak var tituloDaReceita: UINavigationItem!
    // Funcoes de tirar foto
    @IBOutlet weak var imageTake: UIImageView!
    @IBOutlet weak var botaoFoto: UIButton!
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    var eye = false
    var sound = false
    var haptic = false
    var soundEffectPlayer : AVAudioPlayer?
    var recipes : [Recipe] = []
    var labelEyeSide = ""
    var labelEyeFinalState = ""
    var indexReceitaEscolhida : Int = 0
    var contadorInstrucoes : Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.model == "iPhone"{
            AppDelegate.AppUtility.lockOrientation(.portrait)
        }
        let defaults = UserDefaults.standard
        eye = defaults.bool(forConfigKey: .touch)
        sound = defaults.bool(forConfigKey: .sound)
        haptic = defaults.bool(forConfigKey: .haptic)
        let configuration = ARFaceTrackingConfiguration()
        if eye == true {
            sceneView.session.run(configuration)
            sceneView.preferredFramesPerSecond = 5
            sceneView.isHidden = true
        }
    }
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            DispatchQueue.main.async {
                if self.eye == true {
                    self.labelEyeFinalState = self.labelEyeSide
                }
                if self.labelEyeFinalState == "You are blinking right." && self.contadorInstrucoes < self.recipes[self.indexReceitaEscolhida].numeroIntrucoes - 1
                {
                    if self.contadorInstrucoes < 9 {
                        self.contadorInstrucoes += 1
                    }
                    self.play(tipoSom: "passar")
                    self.viewDidLoad()
                    print(self.contadorInstrucoes)
                }
                if(self.labelEyeFinalState == "You are blinking left." && self.contadorInstrucoes != 0)
                {
                    self.play(tipoSom: "voltar")
                    self.contadorInstrucoes -= 1
                    self.viewDidLoad()
                    print(self.contadorInstrucoes)
                }
            }
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let eyeblinkright = anchor.blendShapes[.eyeBlinkRight]
        let eyeblinkleft = anchor.blendShapes[.eyeBlinkLeft]
        let mouthLeft = anchor.blendShapes[.mouthRight]
        let mouthRight = anchor.blendShapes[.mouthLeft]
        self.labelEyeSide = ""
        if eyeblinkright?.decimalValue ?? 0.0 > 0.7 ||  mouthLeft?.decimalValue ?? 0.0 > 0.7
        {
            self.labelEyeSide += "You are blinking left."
        }
        if eyeblinkleft?.decimalValue ?? 0.0 > 0.7 || mouthRight?.decimalValue ?? 0.0 > 0.7{
            self.labelEyeSide += "You are blinking right."
        }
    }
    
    override func viewDidLoad() {
        setupNavigationBackButton()
        recipes = getRecipes()
        updateData()
        botaoTerminarReceita.layer.cornerRadius = 20
        sceneView.delegate = self
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if contadorInstrucoes == recipes[indexReceitaEscolhida].numeroIntrucoes-1{
            contadorInstrucoes = recipes[indexReceitaEscolhida].numeroIntrucoes-1
        }
        else{
            contadorInstrucoes += 1
            viewDidLoad()
        }
        play(tipoSom: "passar")
        if haptic == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    @IBAction func lastStep(_ sender: Any) {
        if contadorInstrucoes == 0{
            contadorInstrucoes = 0
        }
        else{
            contadorInstrucoes -= 1
            viewDidLoad()
        }
        play(tipoSom: "voltar")
        if haptic == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    func setupNavigationBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.isAccessibilityElement = true
        self.navigationItem.rightBarButtonItem?.accessibilityLabel = "Botão para mostrar a lista de ingredientes e etapas da receita"
    }
    func updateData(){
        progressBar.progress = recipes[indexReceitaEscolhida].progressBar[contadorInstrucoes]
        tituloDaReceita.title = "\(recipes[indexReceitaEscolhida].tituloReceita)".localize()
        if recipes[indexReceitaEscolhida].pessoaTurno[contadorInstrucoes] == "Mix"{
            progressBar.progressTintColor = UIColor.magentaTela
            botaoIr.backgroundColor = UIColor.magentaTela
            botaoVoltar.backgroundColor = UIColor.magentaTela
            botaoTerminarReceita.backgroundColor = UIColor.magentaTela
            viewTurno.backgroundColor = UIColor.magentaFundo
            corDoFundoDaTela.backgroundColor = UIColor.magentaFundo
            botaoFoto.backgroundColor = UIColor.magentaTela
            labelImagem.text = "Vocês podem fazer essa etapa juntos!!!".localize()
            lampImage.image = UIImage(named: "Dica - Magenta")
            imagemTurno.image = UIImage(named: "turno.mix")
        }
        if recipes[indexReceitaEscolhida].pessoaTurno[contadorInstrucoes] == "Adulto"{
            progressBar.progressTintColor = UIColor.blueTela
            botaoIr.backgroundColor = UIColor.blueTela
            botaoVoltar.backgroundColor = UIColor.blueTela
            botaoTerminarReceita.backgroundColor = UIColor.blueTela
            viewTurno.backgroundColor = UIColor.blueFundo
            corDoFundoDaTela.backgroundColor = UIColor.blueFundo
            botaoFoto.backgroundColor = UIColor.blueTela
            labelImagem.text = "Siga as instruções abaixo:".localize()
            lampImage.image = UIImage(named: "Dica - Blue")
            imagemTurno.image = UIImage(named: "turno.adulto")
        }
        if recipes[indexReceitaEscolhida].pessoaTurno[contadorInstrucoes] == "Criança"{
            progressBar.progressTintColor = UIColor.orangeTela
            botaoIr.backgroundColor = UIColor.orangeTela
            botaoVoltar.backgroundColor = UIColor.orangeTela
            botaoTerminarReceita.backgroundColor = UIColor.orangeTela
            viewTurno.backgroundColor = UIColor.orangeFundo
            corDoFundoDaTela.backgroundColor = UIColor.orangeFundo
            botaoFoto.backgroundColor = UIColor.orangeTela
            labelImagem.text = "Siga as instruções abaixo:".localize()
            lampImage.image = UIImage(named: "Dica - ORANGE")
            imagemTurno.image = UIImage(named: "turno.child")
        }
        labelTurno.text = "\(recipes[indexReceitaEscolhida].pessoaTurno[contadorInstrucoes])".localize()
        labelIntrucao.text = "\(recipes[indexReceitaEscolhida].descricaoReceita[contadorInstrucoes])".localize()
        labelDica.text = "\(recipes[indexReceitaEscolhida].dicas[contadorInstrucoes])".localize()
        imagemIntrucao.image = recipes[indexReceitaEscolhida].imagemIntrucao[contadorInstrucoes]
        imagemIntrucao.isAccessibilityElement = true
        imagemIntrucao.accessibilityLabel = "Imagem que resume a intrução da etapa atual da receita"
        lampImage.isAccessibilityElement = true
        lampImage.accessibilityLabel = "Icone de dicas com texto ao lado direito"
        botaoFoto.layer.cornerRadius = 0.5 * botaoFoto.bounds.size.width
        botaoFoto.clipsToBounds = true
        botaoFoto.isAccessibilityElement = true
        botaoFoto.accessibilityLabel = "Botão para tirar foto"
        if contadorInstrucoes == recipes[indexReceitaEscolhida].numeroIntrucoes-1{
            botaoTerminarReceita.isHidden = false
            botaoTerminarReceita.layer.cornerRadius = 550
            botaoTerminarReceita.isAccessibilityElement = true
            botaoTerminarReceita.accessibilityLabel = "Botão para terminar a receita, É hora de comer!"
        }else
        {
            botaoTerminarReceita.isHidden = true
        }
        if contadorInstrucoes == 0 {
            botaoVoltar.isHidden = true
        }else{
            botaoVoltar.isHidden = false
            botaoVoltar.isAccessibilityElement = true
            botaoVoltar.accessibilityLabel = "Botão para voltar uma etapa da receita"
        }
        if contadorInstrucoes == recipes[indexReceitaEscolhida].numeroIntrucoes - 1 {
            botaoIr.isHidden = true
        }else {
            botaoIr.isHidden = false
            botaoIr.isAccessibilityElement = true
            botaoIr.accessibilityLabel = "Botão para avançar uma etapa da receita"
        }
        if recipes[indexReceitaEscolhida].dicas[contadorInstrucoes] == "" {
            lampImage.isHidden = true
        }else {
            lampImage.isHidden = false
        }
    }
    func navigation(destino: Destinations) {
        if destino == .forgot{
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.forgot.rawValue) as! ForgotRecipeViewController
            let escolha = indexReceitaEscolhida
            newViewController.escolha = escolha
            self.present(newViewController, animated:true, completion:nil)
        }
        if destino == .end{
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.end.rawValue) as! EndRecipeViewController
            let escolha = indexReceitaEscolhida
            newViewController.indexReceitaEscolhida = escolha
            navigationController?.modalPresentationStyle = .formSheet
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    @IBAction func goRight(_ sender: Any) {
        if contadorInstrucoes == recipes[indexReceitaEscolhida].numeroIntrucoes-1{
            contadorInstrucoes = recipes[indexReceitaEscolhida].numeroIntrucoes-1
        } else{
            contadorInstrucoes += 1
            play(tipoSom: "passar")
            if haptic == true {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            viewDidLoad()
        }
    }
    @IBAction func goLeft(_ sender: Any) {
        contadorInstrucoes -= 1
        play(tipoSom: "voltar")
        if haptic == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        viewDidLoad()
    }
    @IBAction func forgetRecipeButton(_ sender: Any) {
        navigation(destino: .forgot)
    }
    @IBAction func playSound(_ sender: Any) {
        navigation(destino: .end)
        if haptic == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        play(tipoSom: "fim-receita")
    }
    func play(tipoSom : String) {
        if sound == true{
            let urlString = Bundle.main.path(forResource: tipoSom, ofType: "mp3")
            do {
                try? AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                guard let urlString = urlString else {
                    return
                }
                soundEffectPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
                guard let player = soundEffectPlayer else {
                    return
                }
                player.play()
            }
            catch {
                print("Something went wrong! :(")
            }
        }
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
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
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
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
        save(self)
    }
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    @IBAction func timerButton(_ sender: Any) {
        navigation(destino: .timer)
    }
}

