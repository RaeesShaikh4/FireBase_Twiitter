import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    var viewModel : DataViewViewModel!
  
    var selectedUserUUID: String?
    
    @IBOutlet var sortTxtField: UITextField!
    @IBOutlet var profileBTN: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sortTxtField.delegate = self
        viewModel = DataViewViewModel()
        viewModel.didUpdateData = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        fetchUserData()
    }
    
    
    func fetchUserData() {
        viewModel.fetchUserData { error in
            if let error = error {
                print("Error while fetching data: \(error)")
            } else {
                // Assuming viewModel.filteredUsers is not empty
                self.selectedUserUUID = self.viewModel.filteredUsers[0].uuid
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        viewModel.filterContentForSearchText(searchText)
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let currentUser = viewModel.filteredUsers[indexPath.row]
        cell.cellUserNameLabel.text = currentUser.name
        cell.cellEmailLabe.text = currentUser.email
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.filteredUsers[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        homeVC.profileUserID = selectedUser.uuid
        homeVC.name = selectedUser.name
        homeVC.email = selectedUser.email

        if let navigationController = self.navigationController {
            navigationController.pushViewController(homeVC, animated: true)
        } else {
            self.present(homeVC, animated: true, completion: nil)
        }
    }

}

