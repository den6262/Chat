//
//  LoginViewController+handlers.swift
//  Chat
//
//  Created by Deniro21 on 7/20/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Funcs
    func handleRegister() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text
        else {
            print("Error")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1) {
                
                //    let uploadData = self.profileImageView.image?.pngData()!
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata: StorageMetadata?, error: Error?) in
                    if error != nil {
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        if let profileImageUrl = url?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                    })
                })
                
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://chat-5124a.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            //self.messagesController?.fetchUserAndSetUpNavBarTitle()
            //self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User(dictionary: values)
            
            self.messagesController?.setUpNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
