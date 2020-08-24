//
//  LimitReachedController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/20/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class LimitReachedController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: LimitReachedDelegate?
    
    var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .heavy, scale: .small)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: config)!
            .withRenderingMode(.alwaysOriginal).withTintColor(.lightGray), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .clear
        b.tintColor = .white
        return b
    }()
    
    let header: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: fontString, size: 17)
        l.textColor = .lightGray
        l.text = "Daily Limit Reached".uppercased()
        l.textAlignment = .center
        return l
    }()
    
    let imView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium, scale: .large)
        iv.image = UIImage(systemName: "star", withConfiguration: config)?
            .withRenderingMode(.alwaysOriginal).withTintColor(.white)
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let subheader: UILabel = {
        let label = UILabel()
        label.text = "Upgrade for more puzzles"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Black", size: 22)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var upgradeYesButton: UIButton = {
        let button = UIButton(type: .system)
         button.setTitle("See Prices", for: .normal)
         button.titleLabel?.font = UIFont(name: fontString, size: 22)
         button.backgroundColor = CommonUI().csBlue
         button.layer.cornerRadius = 10
         button.clipsToBounds = true
         button.addTarget(self, action: #selector(upgradeYesAction), for: .touchUpInside)
         button.setTitleColor(.white, for: .normal)
         return button
    }()
    
    lazy var upgradeNoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Not Now", for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 22)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    var vstack: UIStackView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBar.isHidden = true
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        view.addSubview(blurredEffectView)
        
        closeButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        view.addSubview(closeButton)
        
        vstack = CommonUI().configureStackView(arrangedSubViews: [header, imView, subheader, upgradeYesButton, upgradeNoButton])
        vstack.distribution = .fillProportionally
        vstack.spacing = 30
        vstack.setCustomSpacing(60, after: header)
        vstack.setCustomSpacing(60, after: subheader)
        view.addSubview(vstack)
        
        view.backgroundColor = .clear
    }
    
    func configAutoLayout() {
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        
        vstack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20).isActive = true
        vstack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    // MARK: - Selectors
    
    @objc func dismissAction() {
        delegate?.didDismiss()
    }
    
    @objc func upgradeYesAction() {
        delegate?.didSelectUpgrade()
    }
    
}
