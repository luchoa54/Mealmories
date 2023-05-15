import Foundation
import UIKit
import NotificationCenter


class ListRecipesViewController : UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var confetti: UIImageView!
    //Outlets da receita de destaque
    @IBOutlet weak var fundoCards: UIView!
    @IBOutlet weak var timeCard: UILabel!
    @IBOutlet weak var difficultyCard: UILabel!
    @IBOutlet weak var ageCard: UILabel!
    @IBOutlet weak var nameCard: UILabel!
    @IBOutlet weak var imageCard: UIImageView!
    
    @IBOutlet weak var difficultyCardImage: UIImageView!
    @IBOutlet weak var scrollRecipesHeight: NSLayoutConstraint!
    //Outlets das Receitas Rapidas
    @IBOutlet weak var tableViewReceitasRapidas: UITableView!
    @IBOutlet weak var tableViewReceitasRapidasHeight: NSLayoutConstraint!
    
    var indexReceitas : Int = -1
    
    let randomInt = Int.random(in: 0..<5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.navigationController?.navigationBar.tintColor = UIColor.label
        
        setupNavigationBackButton()
        tableViewReceitasRapidas.dataSource = self
        tableViewReceitasRapidas.delegate = self
        fundoCards.layer.borderColor = UIColor.magentaTela?.cgColor
        fundoCards.layer.borderWidth = 3
        confetti.layer.opacity = 0.4
        
        self.scrollRecipesHeight.constant += self.tableViewReceitasRapidasHeight.constant - 100
        
        setReceitaDestaque()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.allButUpsideDown)
        
        self.navigationController?.isNavigationBarHidden = false
        let appearence = UINavigationBarAppearance()
        appearence.configureWithTransparentBackground()
        appearence.shadowColor = .clear
        appearence.backgroundColor = .clear
        appearence.backgroundImage = nil
        appearence.shadowImage = nil
        self.navigationController?.navigationBar.standardAppearance = appearence
        
    }
    
    override func viewWillLayoutSubviews() {
        let recipes = getChosenRecipe()
        self.tableViewReceitasRapidasHeight.constant = (self.tableViewReceitasRapidas.contentSize.height * CGFloat(recipes.count))
    }
    
   
    
    func setupNavigationBackButton(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func setReceitaDestaque() {
        
        let receitaDeDestaque =  getChosenRecipe()
        
        timeCard.text = "\(receitaDeDestaque[randomInt].tempoDePreparo)".localize()
        difficultyCard.text = "\(receitaDeDestaque[randomInt].dificuldade)".localize()
        ageCard.text = "+\(receitaDeDestaque[randomInt].idadeRecomendada) anos".localize()
        nameCard.text = "\(receitaDeDestaque[randomInt].nomeDaReceita)".localize()
        imageCard.image = receitaDeDestaque[randomInt].imagemReceita
        imageCard.isAccessibilityElement = true
        imageCard.accessibilityLabel = "Imagem da receita em destaque, \(receitaDeDestaque[randomInt].nomeDaReceita)"
        difficultyCardImage.image = UIImage(named: "\(receitaDeDestaque[randomInt].dificuldade)-32px")
        
    }
    
    @IBAction func ClickReceitaDestaque(_ sender: Any) {
        indexReceitas = randomInt
        navigation(destino: .chosen)
        
    }
    
    @IBAction func ConfigButton(_ sender: Any) {
        navigation(destino: .config)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let recipes = getChosenRecipe()
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipes = getChosenRecipe()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipesTableViewCell
        cell.imageTableView.image = recipes[indexPath.row].imagemReceita
        cell.nameTableView.text = "\(recipes[indexPath.row].nomeDaReceita)".localize()
        cell.ageTableView.text = "+\(recipes[indexPath.row].idadeRecomendada) anos".localize()
        cell.dificultyTableView.text = "\(recipes[indexPath.row].dificuldade)".localize()
        cell.timeTableView.text = "\(recipes[indexPath.row].tempoDePreparo)".localize()
        cell.dificultyImageView.image = UIImage(named: "\(recipes[indexPath.row].dificuldade)-16px")
        cell.selectionStyle = .none
        return cell
    }
    
    func navigation(destino: Destinations) {
        if destino == .chosen {
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.chosen.rawValue) as! ChosenRecipeViewController
            
            let escolha = indexReceitas
            newViewController.indexReceitaEscolhida = escolha
            
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        
        if destino == .config {
            let storyBoard: UIStoryboard = UIStoryboard(name: destino.rawValue, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: Destinations.config.rawValue) as! ConfigViewController
            
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexReceitas = indexPath.row
        navigation(destino: .chosen)
    }

}


