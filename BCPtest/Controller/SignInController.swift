//
//  SignInController.swift
//  BCPtest
//
//  Created by Guest on 8/2/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class SignInController: UIViewController {
    
    // MARK: - Properties
    
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
        vstack = CommonUI().configureStackView(arrangedSubViews: [
            titleLabel, signInUpSegment, emailField, usernameField, passwordField, signInUpButton])
        vstack.spacing = 20
        vstack.setCustomSpacing(60, after: titleLabel)
        view.addSubview(vstack)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logoImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100).isActive = true
        logoImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        
        vstack.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: -20).isActive = true
        vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    // MARK: - Selectors
    
    @objc func signInUpAction() {
        present(TabBarController(), animated: true)
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
    
    // MARK: - Helper
    
    func configInputField(placeHolder: String, isHidden: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.isHidden = isHidden
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.textColor = .white
        tf.font = UIFont(name: fontStringLight, size: 23)
        tf.placeholder = placeHolder
        tf.textAlignment = .left
        tf.backgroundColor = CommonUI().blackColorLight
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
        return tf
    }
    
    func configSegment(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        let font = UIFont(name: fontString, size: 23)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: CommonUI().csRed], for: .selected)
        sc.setTitleTextAttributes([.font: font!, .foregroundColor: UIColor.lightGray], for: .normal)
        sc.tintColor = .lightGray
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = CommonUI().blackColor
        sc.layer.cornerRadius = 20
        sc.clipsToBounds = true
        return sc
    }
    
    func configButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 25)
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 3.5
        button.layer.borderColor = UIColor(red: 33/255, green: 34/255, blue: 37/255, alpha: 1).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(signInUpAction), for: .touchUpInside)
        button.setTitleColor(CommonUI().csRed, for: .normal)
        
        return button
    }
}
