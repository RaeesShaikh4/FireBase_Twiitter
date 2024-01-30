
import UIKit
import FirebaseAuth

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DataViewViewModelDelegate {
    
    
    // ----------
    func didUpdateData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private var viewModel: DataViewViewModel?

    var selectedUserUUID: String?

    @IBOutlet var sortTxtField: UITextField!
    @IBOutlet var profileBTN: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize viewModel
        viewModel = DataViewViewModel()

        // Set delegates
        tableView.delegate = self
        tableView.dataSource = self
        sortTxtField.delegate = self
        viewModel?.delegate = self
       
        // Fetch user data
        fetchUserData()
    }

    func fetchUserData() {
        viewModel?.fetchUserData { error in
            if let error = error {
                print("Error while fetching data: \(error)")
            } else {
                if !self.viewModel!.filteredUsers.isEmpty {
                    self.selectedUserUUID = self.viewModel!.filteredUsers[0].uuid
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        viewModel?.filterContentForSearchText(searchText)
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredUsers.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        if let currentUser = viewModel?.filteredUsers[indexPath.row] {
            cell.cellUserNameLabel.text = currentUser.name
            cell.cellEmailLabe.text = currentUser.email
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row at: \(indexPath.row)")

        if let selectedUser = viewModel?.filteredUsers[indexPath.row],
           let navigationController = self.navigationController {
            // Now, navigate to the ViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

            // Pass the UUID of the selected user to the ViewController
            homeVC.selectedUserID = selectedUser.uuid
            print("homeVC Selecteduuid : \(homeVC.selectedUserID)")

            // Push the ViewController to the navigation stack
            navigationController.pushViewController(homeVC, animated: true)
        } else {
            // Handle the case where navigation controller is not available
            print("Error: Navigation controller is nil or selected user is not available.")
        }
    }

}
