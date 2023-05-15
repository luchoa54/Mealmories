//
//  ChoosenRecipeViewController.swift
//  Challenge04LGBB
//
//  Created by Luciano Uchoa on 26/08/22.
//

import Foundation
import UIKit
import AVFoundation

class ChosenRecipeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var tableIngredients: UITableView!
    @IBOutlet weak var tableIngredientsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableEtapas: UITableView!
    @IBOutlet weak var tableEtapasHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imagemReceitaEscolhida: UIImageView!
    
    @IBOutlet weak var nomeReceitaEscolhida: UILabel!
    @IBOutlet weak var tempoReceitaEscolhida: UILabel!
    @IBOutlet weak var dificultyReceitaEscolhida: UILabel!
    @IBOutlet weak var dificultyReceitaEscolhidaImage: UIImageView!
    @IBOutlet weak var ageReceitaEscolhida: UILabel!
    
    var ingredientsList : [String] = [String]()
    var etapasList : [String] = [String]()
    var chosenRecipe : [ChosenRecipeModel] = []
    var soundEffect = false
    var hapticEffect = false
    
    @IBOutlet weak var startButton : UIButton!
    
    var player : AVAudioPlayer?
    var indexReceitaEscolhida : Int = 0
    var contadorReceita : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBackButton()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem?.isAccessibilityElement = true
        self.navigationItem.rightBarButtonItem?.accessibilityLabel = "Botão de configurações de som e interação sem toque"
        setChosenRecipe()
        startButton.layer.cornerRadius = 20
        self.setTableView()
        if chosenRecipe[indexReceitaEscolhida].ingredientes.count >= 5 {
            self.scrollViewHeight.constant += self.tableIngredients.contentSize.height - 260.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.allButUpsideDown)
        
        let defaults = UserDefaults.standard
        soundEffect = defaults.bool(forKey: "Sound")
        hapticEffect = defaults.bool(forKey: "Haptic")
        
    }
    
    private func setTableView(){
        self.tableIngredients.delegate = self
        self.tableIngredients.dataSource = self
        self.tableIngredients.register(UINib(nibName: "TableIngredientCell", bundle: nil), forCellReuseIdentifier: "TableIngredientCell")
        self.tableIngredients.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        self.tableEtapas.delegate = self
        self.tableEtapas.dataSource = self
        self.tableEtapas.register(UINib(nibName: "TableEtapasCell", bundle: nil), forCellReuseIdentifier: "TableEtapasCell")
        self.tableEtapas.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.setTabeleViewData()
    }
    
    override func viewWillLayoutSubviews() {
        self.tableIngredientsHeight.constant = self.tableIngredients.contentSize.height
        self.tableEtapasHeight.constant = self.tableEtapas.contentSize.height
    }
    
    private func setTabeleViewData(){
        chosenRecipe = getChosenRecipe()
        for i in 0...chosenRecipe[indexReceitaEscolhida].ingredientes.count - 1 {
            self.ingredientsList.append(chosenRecipe[indexReceitaEscolhida].ingredientes[i])
        }
        for i in 0...chosenRecipe[indexReceitaEscolhida].etapas.count - 1 {
            self.etapasList.append(chosenRecipe[indexReceitaEscolhida].etapas[i])
        }
        
        self.tableIngredients.reloadData()
        self.tableEtapas.reloadData()
        self.tableIngredients.invalidateIntrinsicContentSize()
        self.tableEtapas.invalidateIntrinsicContentSize()
    }
    
    @IBAction func configbutton(_ sender: Any) {
        navigation(destino: .config)
    }
    
    func setupNavigationBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func navigation(destino:Destinations){
        if destino == .recipe{
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.recipe.rawValue) as! RecipeViewController
            
            let escolha = indexReceitaEscolhida
            newViewController.indexReceitaEscolhida = escolha
            _ = contadorReceita
            newViewController.contadorInstrucoes = 0
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }
        if destino == .config{
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.config.rawValue) as! ConfigViewController
            
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }
        
    }
    
    
    
    @IBAction func playSound(_ sender: Any){
        navigation(destino: .recipe)
        if hapticEffect == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        if soundEffect == true {
            if let player = player, player.isPlaying {
                
            } else {
                
                let urlString = Bundle.main.path(forResource: "iniciar-receita", ofType: "mp3")
                
                do {
                    
                    try? AVAudioSession.sharedInstance().setMode(.default)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    
                    guard let urlString = urlString else {
                        return
                    }
                    
                    player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
                    
                    guard let player = player else {
                        return
                    }
                    
                    player.play()
                }
                catch {
                    print("Something went wrong! :(")
                }
            }
        }
    }
    
    
    func setChosenRecipe()  {
        
        let chosenRecipe = getChosenRecipe()
        
        imagemReceitaEscolhida.image = chosenRecipe[indexReceitaEscolhida].imagemReceita
        imagemReceitaEscolhida.isAccessibilityElement = true
        imagemReceitaEscolhida.accessibilityLabel = "Imagem da Receita Escolhida, \(chosenRecipe[indexReceitaEscolhida].nomeDaReceita)"
        
        nomeReceitaEscolhida.text = "\(chosenRecipe[indexReceitaEscolhida].nomeDaReceita)".localize()
        nomeReceitaEscolhida.accessibilityLabel = "Nome da Receita Escolhida, \(chosenRecipe[indexReceitaEscolhida].nomeDaReceita)"
        
        tempoReceitaEscolhida.text = "\(chosenRecipe[indexReceitaEscolhida].tempoDePreparo)".localize()
        tempoReceitaEscolhida.accessibilityLabel = "Tempo estimado de duração da receita escolhida, \(chosenRecipe[indexReceitaEscolhida].tempoDePreparo)"
        
        dificultyReceitaEscolhida.text = "\(chosenRecipe[indexReceitaEscolhida].dificuldade)".localize()
        dificultyReceitaEscolhida.accessibilityLabel = "Dificuldade da receita escolhida, \(chosenRecipe[indexReceitaEscolhida].dificuldade)"
        dificultyReceitaEscolhidaImage.image = UIImage(named: "\(chosenRecipe[indexReceitaEscolhida].dificuldade)-32px")
        
        ageReceitaEscolhida.text = "+ \(chosenRecipe[indexReceitaEscolhida].idadeRecomendada) anos".localize()
        ageReceitaEscolhida.accessibilityLabel = "Faixa etária da receita escolhida, \(chosenRecipe[indexReceitaEscolhida].idadeRecomendada) anos ou mais"
    }
    
    
}

class TableIngredientCell2: UITableViewCell{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var LabelCell: UILabel!
}

class TableEtapasCell2: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageEtapaCell: UIImageView!
    @IBOutlet weak var labelEtapaCell: UILabel!
}

extension ChosenRecipeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        if tableView == self.tableIngredients {
            count = self.ingredientsList.count
        }
        
        if tableView == self.tableEtapas {
            count = self.etapasList.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableIngredients{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableIngredientCell
            
            cell.labelCell.text = self.ingredientsList[indexPath.item].localize()
            cell.bgView.backgroundColor = UIColor.magentaFundo
            cell.imageCell.image = UIImage(named: "ingrediente")
            
            return cell
        }
        
        if tableView == self.tableEtapas{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! TableEtapasCell
            
            cell.labelEtapaCell.text = self.etapasList[indexPath.item].localize()
            cell.backView.backgroundColor = UIColor.orangeFundo
            cell.imageEtapaCell.image = UIImage(named: "Numero \(indexPath.item + 1)")
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableEtapasCell else {
            fatalError("Failed to load tableView")
        }
        
        return cell
    }
}


