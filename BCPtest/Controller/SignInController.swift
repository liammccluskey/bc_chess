//
//  SignInController.swift
//  BCPtest
//
//  Created by Guest on 8/2/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInController: UIViewController {
    
    // MARK: - Properties
    
    var keyboardShown = false
    
    let commonUI = CommonUI()
    
    var userDBMS: UserDBMS!
    var delegate: SignInDelegate?
    
    var imStack: UIStackView!
    var logoImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "logo_main").withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Puzzled"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Heavy", size: 40)
        label.backgroundColor = .clear
        return label
    }()
    var signInUpSegment: UISegmentedControl!
    var signInUpButton: UIButton!
    
    var vstack: UIStackView!
    var emailField: UITextField!
    var passwordField: UITextField!
    var usernameField: UITextField!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDBMS = UserDBMS()
        userDBMS.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        configUI()
        configAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow() {
        print("show")
        if logoImage.isHidden == true { return }
        UIView.animate(withDuration: 0.2) {
            self.logoImage.isHidden = true
            self.view.layoutIfNeeded()
        }
    
    }

    @objc func keyboardWillHide() {
        print("hide")
        
        if logoImage.isHidden == false { return }
        UIView.animate(withDuration: 0.2) {
            self.logoImage.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Config
    
    func configUI() {
        
        imStack = commonUI.configureStackView(arrangedSubViews: [logoImage])
        view.addSubview(imStack)
        
        signInUpSegment = configSegment(items: ["Sign In", "Register"])
        emailField = configInputField(placeHolder: "  Email")
        usernameField = configInputField(placeHolder: "  Username", isHidden: true)
        
        passwordField = configInputField(placeHolder: "  Password", isSecure: true)
        signInUpButton = configButton(title: "Sign In")
        vstack = commonUI.configureStackView(arrangedSubViews: [
            titleLabel, signInUpSegment, emailField, usernameField, passwordField])
        vstack.spacing = 20
        vstack.setCustomSpacing(40, after: titleLabel)
        view.addSubview(vstack)
        view.addSubview(signInUpButton)
        
        view.backgroundColor = commonUI.blackColor
    }
    
    func configAutoLayout() {
        imStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        imStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //imStack.heightAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        imStack.widthAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        
        
        vstack.topAnchor.constraint(equalTo: imStack.bottomAnchor, constant: -30).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        signInUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        signInUpButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        signInUpButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
    }
    
    // MARK: - Selectors
    
    @objc func signInUpAction() {
        guard let email = emailField.text,
            let password = passwordField.text,
            let username = usernameField.text
            else {return}
        if signInUpSegment.selectedSegmentIndex == 0 {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if authResult != nil {
                    let userHasCoreData: Bool = self.userDBMS.getPuzzledUser() != nil
                    if userHasCoreData == false {
                        self.userDBMS.initExistingUserCoreData(uid: Auth.auth().currentUser!.uid)
                    }
                    self.delegate?.notifyOfSignIn()
                } else {self.showSignInUpAlert(message: error!.localizedDescription); return }
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if authResult != nil {
                    self.userDBMS.initUserData(uid: Auth.auth().currentUser!.uid, username: username)
                    self.delegate?.notifyOfSignIn()
                } else {self.showSignInUpAlert(message: error!.localizedDescription); return }
            }
        }

    }
    
    @objc func segmentAction() {
        let isSignIn = signInUpSegment.selectedSegmentIndex == 0 ? true : false
        DispatchQueue.main.async {
             if isSignIn {
                UIView.animate(withDuration: 0.2) {
                    self.usernameField.isHidden = true
                    self.signInUpButton.setTitle("Sign In", for: .normal)
                    self.view.layoutIfNeeded()
                }
             } else {
                UIView.animate(withDuration: 0.2) {
                    self.usernameField.isHidden = false
                    self.signInUpButton.setTitle("Register", for: .normal)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Alerts
    
    func showSignInUpAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\n" + message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Helper
    
    func configInputField(placeHolder: String, isHidden: Bool = false, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.isHidden = isHidden
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.textColor = .white
        tf.font = UIFont(name: fontStringLight, size: 23)
        tf.placeholder = placeHolder
        tf.textAlignment = .left
        tf.backgroundColor = commonUI.blackColorLight
        tf.layer.cornerRadius = 5
        tf.clipsToBounds = true
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = isSecure
        if isSecure {
            tf.addTarget(self, action: #selector(keyboardWillHide), for: UIControl.Event.editingDidEnd)
        }
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        let font = UIFont(name: fontString, size: 22)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.darkGray], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .black
        sc.selectedSegmentTintColor = .black
        sc.layer.cornerRadius = 20
        sc.clipsToBounds = true
        sc.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return sc
    }
    
    func configButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 22)
        button.backgroundColor = commonUI.greenCorrect
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(signInUpAction), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

extension SignInController: UserDBMSDelegate {
    func sendUser(user: User?) {
        print(user)
    }
}
