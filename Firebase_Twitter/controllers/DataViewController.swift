import UIKit
import FirebaseFirestore

struct Uuser {
    var uuid: String
    var name: String
    var email: String
}

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    var user: [Uuser] = []
    var filteredUser: [Uuser] = []
    var selectedUserUUID: String?
    
    @IBOutlet var sortTxtField: UITextField!
    @IBOutlet var profileBTN: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sortTxtField.delegate = self
        fetchUserData()
    }
    
    func fetchUserData() {
        let DataBase = Firestore.firestore()
        DataBase.collection("users").getDocuments { (querySnapShot, error) in
            if let error = error {
                print("Error while fetching data: \(error)")
            } else {
                self.user = querySnapShot?.documents.compactMap({ document in
                    let data = document.data()
                    let uuid = document.documentID
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    return Uuser(uuid: uuid, name: name, email: email)
                    
                }) as! [Uuser]
                self.filteredUser = self.user
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterContentForSearchText(searchText)
        return true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredUser = user
        } else {
            filteredUser = user.filter {
                $0.name.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let currentUser = user[indexPath.row]
        cell.cellUserNameLabel.text = currentUser.name
        cell.cellEmailLabe.text = currentUser.email
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedUser = user[indexPath.row]
        selectedUserUUID = selectedUser.uuid
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        
        homeVC.profileUserID = selectedUserUUID!
              homeVC.name = selectedUser.name
              homeVC.email = selectedUser.email
        
        
        self.navigationController?.pushViewController(homeVC, animated: true) ?? self.present(homeVC, animated: true, completion: nil)
    }
 

    
}

