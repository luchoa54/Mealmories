import Foundation
import UIKit

class ForgotRecipeViewController: UIViewController {
    
    @IBOutlet weak var tableIngredients: UITableView!
    @IBOutlet weak var tableIngredientsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableEtapas: UITableView!
    @IBOutlet weak var tableEtapasHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    private var ingredientsList : [String] = [String]()
    private var etapasList : [String] = [String]()
    
    var choosenrecipe : [ChosenRecipeModel] = []
    var escolha : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.AppUtility.lockOrientation(.portrait)
        self.setTableView()
        if choosenrecipe[escolha].ingredientes.count >= 5 {
            self.scrollViewHeight.constant += self.tableIngredients.contentSize.height - 360.0
        }
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
        choosenrecipe = getChosenRecipe()
        for i in 0...choosenrecipe[escolha].ingredientes.count - 1 {
            self.ingredientsList.append(choosenrecipe[escolha].ingredientes[i])
        }
        for i in 0...choosenrecipe[escolha].etapas.count - 1 {
            self.etapasList.append(choosenrecipe[escolha].etapas[i])
        }
        
        self.tableIngredients.reloadData()
        self.tableEtapas.reloadData()
        self.tableIngredients.invalidateIntrinsicContentSize()
        self.tableEtapas.invalidateIntrinsicContentSize()
    }
}

class TableIngredientCell: UITableViewCell{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var labelCell: UILabel!
}

class TableEtapasCell :UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageEtapaCell: UIImageView!
    @IBOutlet weak var labelEtapaCell: UILabel!
}

extension ForgotRecipeViewController: UITableViewDataSource, UITableViewDelegate {
    
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


