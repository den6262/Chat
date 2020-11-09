//
//  NewMessageController.swift
//  Chat
//
//  Created by Deniro21 on 7/19/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    //MARK: - Vars
    let cellId = "Cell"
    
    var messagesController: MessagesController?
    
    var users = [User]()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
    }
    
    //MARK: - Funcs
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                
                self.users.append(user)
                
                DispatchQueue(label: "").async {
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TableView D&DT
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        
        if let profileImageUrl = user.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
}


