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
    
    let commonUI = CommonUI()
    
    var userDBMS: UserDBMS!
    var delegate: SignInDelegate?
    
    var logoImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "logo").withRenderingMode(.alwaysOriginal)
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
    
    // MARK: - Config
    
    func configUI() {
        
        view.addSubview(logoImage)
        
        signInUpSegment = configSegment(items: ["SIGN IN", "REGISTER"])
        emailField = configInputField(placeHolder: "  Email")
        usernameField = configInputField(placeHolder: "  Username", isHidden: true)
        
        passwordField = configInputField(placeHolder: "  Password")
        signInUpButton = configButton(title: "SIGN IN")
        vstack = commonUI.configureStackView(arrangedSubViews: [
            titleLabel, signInUpSegment, emailField, usernameField, passwordField, signInUpButton])
        vstack.spacing = 20
        vstack.setCustomSpacing(60, after: titleLabel)
        view.addSubview(vstack)
        
        view.backgroundColor = commonUI.blackColor
    }
    
    func configAutoLayout() {
        logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        logoImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80).isActive = true
        logoImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80).isActive = true
        logoImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        vstack.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 5).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
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
                    print("succes log in")
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
                    self.signInUpButton.setTitle("SIGN IN", for: .normal)
                    self.view.layoutIfNeeded()
                }
             } else {
                UIView.animate(withDuration: 0.2) {
                    self.usernameField.isHidden = false
                    self.signInUpButton.setTitle("REGISTER", for: .normal)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Alerts
    
    func showSignInUpAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.setTitle(font: UIFont(name: fontString, size: 23), color: .lightGray)
        alert.setMessage(font: UIFont(name: fontStringLight, size: 20), color: .white)
        alert.setTint(color: commonUI.csRed)
        alert.setBackgroundColor(color: commonUI.blackColor)
        alert.view.layer.borderColor = commonUI.blackColorLight.cgColor
        alert.view.layer.borderWidth = 10
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Helper
    
    func configInputField(placeHolder: String, isHidden: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.isHidden = isHidden
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.textColor = .white
        tf.font = UIFont(name: fontStringLight, size: 23)
        tf.placeholder = placeHolder
        tf.textAlignment = .left
        tf.backgroundColor = commonUI.blackColorLight
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
        return tf
    }
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        let font = UIFont(name: fontString, size: 23)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: commonUI.csRed], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.lightGray], for: .normal)
        sc.tintColor = .lightGray
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = commonUI.blackColor
        sc.layer.cornerRadius = 20
        sc.clipsToBounds = true
        return sc
    }
    
    func configButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 25)
        button.backgroundColor = commonUI.blackColor
        button.layer.borderWidth = 3.5
        button.layer.borderColor = UIColor(red: 33/255, green: 34/255, blue: 37/255, alpha: 1).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(signInUpAction), for: .touchUpInside)
        button.setTitleColor(commonUI.csRed, for: .normal)
        
        return button
    }
}

extension SignInController: UserDBMSDelegate {
    func sendUser(user: User?) {
        print(user)
    }
}
