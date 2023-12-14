import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentViewController: UIViewController {

    var profileUserId: String?
    var comments: [[String: String]] = []
    let db = Firestore.firestore()

    @IBOutlet var entireCommentView: UIView!
    @IBOutlet var CommentTxtField: UITextField!
    @IBOutlet var commentTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        loadComments()
    }

    @IBAction func showAndHideBTN(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func sendBTN(_ sender: UIButton) {
        print("sendBTN called")
        guard let commentText = CommentTxtField.text, !commentText.isEmpty, let profileUserId = profileUserId else {
            print("Error: Missing comment text or profileUserId.")
            return
        }
        // Saving the comment in Firebase
        saveCommentsInFirebase(profileUserId: profileUserId, comment: commentText)
        // Clearing textfield
        CommentTxtField.text = ""
    }

    func saveCommentsInFirebase(profileUserId: String, comment: String) {
        print("saveCommentsInFirebase called ---")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID is nil.")
            return
        }

        let profileUserRef = db.collection("users").document(profileUserId)

        // Creating a dictionary for user ID and comment
        let commentData = ["UserID": userId, "Comment": comment]

        // Updating the "comments" field in the user document
        profileUserRef.updateData(["comments": FieldValue.arrayUnion([commentData])]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                // Commenting saved successfully
                print("Comment saved successfully.")
                self.loadComments() // Trying to reloading comments after a successful update
            }
        }
    }

    func loadComments() {
        guard let profileUserId = profileUserId else {
            print("Error: profileUserId is nil.")
            return
        }

        let ProfileuserRef = db.collection("users").document(profileUserId)

        ProfileuserRef.getDocument { document, error in
            if let document = document, document.exists {
                // getting comments array
                if let commentsArray = document.data()?["comments"] as? [[String: String]] {
                    self.comments = commentsArray
                    print("Comments loaded successfully: \(self.comments)")
                    DispatchQueue.main.async {
                        self.commentTableView.reloadData()
                    }
                } else {
                    print("Error: commentsArray is nil or not of the expected format")
                }
            } else {
                print("Error fetching comment document: \(error)")
            }
        }
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = comments[indexPath.row]
        print("Comment at index \(indexPath.row): \(comment)")
        if let commentText = comment["Comment"] {
            cell.textLabel?.text = "\(commentText)"
        }
        return cell
    }
}
