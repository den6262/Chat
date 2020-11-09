//
//  LoginViewController.swift
//  Chat
//
//  Created by Deniro21 on 7/18/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: - Vars
    weak var messagesController: MessagesController?
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(inputsContainerView)
        self.view.addSubview(loginRegisterButtonView)
        self.view.addSubview(profileImageView)
        self.view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerViewConstraints()
        setupRegisterButtonViewConstraints()
        setupProfileImageViewConstraints()
        setupLoginRegisterSegmentedControl()
        
        
        self.view.backgroundColor = UIColor(r: 25, g: 129, b: 46)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    //MARK: - Helper funcs and setup views
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButtonView: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor(r: 83, g: 156, b: 97)
        
        btn.addTarget(self, action: #selector(LoginViewController.handleLoginRegister), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                return
            }
            
            self.messagesController?.fetchUserAndSetUpNavBarTitle()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameFieldSeparator: UIView = {
        let sp = UIView()
        sp.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()
    
    let emailFieldSeparator: UIView = {
        let sp = UIView()
        sp.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sp.translatesAutoresizingMaskIntoConstraints = false
        return sp
    }()
    
    lazy var profileImageView: UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "ProfileImage")
        pf.contentMode = .scaleAspectFill
        pf.translatesAutoresizingMaskIntoConstraints = false
        
        pf.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSelectProfileImageView)))
        pf.isUserInteractionEnabled = true
        
        return pf
    }()
    
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButtonView.setTitle(title, for: .normal)
        
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                          multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                            multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                                                                                  multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setupLoginRegisterSegmentedControl() {
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupInputsContainerViewConstraints() {
        inputsContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(passwordTextField)
        
        inputsContainerView.addSubview(nameFieldSeparator)
        inputsContainerView.addSubview(emailFieldSeparator)
        
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 8).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        nameFieldSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameFieldSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameFieldSeparator.widthAnchor.constraint(equalTo: nameTextField.widthAnchor).isActive = true
        nameFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailFieldSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailFieldSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailFieldSeparator.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        emailFieldSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setupRegisterButtonViewConstraints() {
        loginRegisterButtonView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginRegisterButtonView.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButtonView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButtonView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupProfileImageViewConstraints() {
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
