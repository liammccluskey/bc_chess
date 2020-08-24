//
//  UpgradeConfirmationController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/20/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class UpgradeConfirmationController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: LimitReachedDelegate?
    
    var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .heavy, scale: .small)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: config)!
            .withRenderingMode(.alwaysOriginal).withTintColor(.darkGray), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .clear
        b.tintColor = .white
        return b
    }()
    
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
        
        view.backgroundColor = .clear
    }
    
    func configAutoLayout() {
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
    }
    
    // MARK: - Selectors
    
    @objc func dismissAction() {
        delegate?.didDismiss()
    }
}
