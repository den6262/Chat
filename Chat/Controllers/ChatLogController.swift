//
//  ChatLogController.swift
//  Chat
//
//  Created by Deniro21 on 7/30/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageZoomable {
    
    //MARK: - Vars
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var messages = [Message]()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    let cellId = "cellId"
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
        
    }
    
    //MARK: - Funcs & Setup Views
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else { return }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView(image: #imageLiteral(resourceName: "upload_image_icon"))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else {
            handleImageSelectedForInfo(info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(_ url: URL) {
        let fileName = UUID().uuidString + ".mov"
        let ref = Storage.storage().reference().child("message_movies").child(fileName)
        
        let uploadTask = ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            ref.downloadURL(completion: { (downloadUrl, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                if let videoUrl = downloadUrl?.absoluteString {
                    if let thumbnailImage = self.thumbnailForVideoUrl(url) {
                        self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                            let properties: [String: Any] = ["videoUrl": videoUrl,
                                                             "imageUrl": imageUrl,
                                                             "imageWidth": thumbnailImage.size.width,
                                                             "imageHeight": thumbnailImage.size.height]
                            
                            self.sendMessageWithProperties(properties: properties)
                        })
                    }
                }
            })
        }
        uploadTask.observe(.progress) { (snapshot) in
            if let completionUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completionUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailForVideoUrl(_ videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print(error)
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage) { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        completion(imageUrl)
                    }
                })
                
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    /*
     func setupKeyboardObservers() {
     NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     
     NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     override func viewDidDisappear(_ animated: Bool) {
     NotificationCenter.default.removeObserver(self)
     }
     
     @objc func handleKeyboardWillHide(notification: Notification) {
     let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
     
     containerViewBottomAnchor?.constant = 0
     
     UIView.animate(withDuration: keyboardDuration) {
     self.view.layoutIfNeeded()
     }
     }
     
     @objc func handleKeyboardWillShow(notification: Notification) {
     let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
     let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
     
     containerViewBottomAnchor?.constant = -keyboardFrame.height
     
     UIView.animate(withDuration: keyboardDuration) {
     self.view.layoutIfNeeded()
     }
     }
     
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.delegate = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.row]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            
            // h1/w1 = h2/w2
            // (h1*w2)/w1 = h2
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)],
                                                   context: nil)
    }
    
    @objc func handleSend() {
        let properties = ["text": inputTextField.text!] as [String : Any]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        //        properties.forEach { (key: String, value: Any) in
        //            values[key] = value
        //        }
        
        properties.forEach {values[$0] = $1}
        
        childRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key!
            userMessageRef.updateChildValues([messageId: 1])
            
            let recepientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recepientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func performZoomInForImageView(_ imageView: UIImageView) {
        
        startingImageView = imageView
        startingImageView?.isHidden = true
        
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut(_:))))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // h2 = h1*w2/w1
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view as? UIImageView {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }) { (complete) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
