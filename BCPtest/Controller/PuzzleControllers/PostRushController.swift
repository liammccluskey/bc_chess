//
//  PostRushController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/14/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class PostRushController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: PostRushDelegate?
    
    let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: fontString, size: 30)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = CommonUI().csRed
        l.text = "Summary"
        l.alpha = 1
        return l
    }()
    
    var buttonStack: UIStackView!
    var playAgainButton: UIButton!
    var exitButton: UIButton!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        view.addSubview(headerLabel)
        
        playAgainButton = configButton(title: "Play Again", tag: 0, textColor: CommonUI().csRed)
        exitButton = configButton(title: "Exit", tag: 1, textColor: CommonUI().redColor)
        buttonStack = CommonUI().configureStackView(arrangedSubViews: [
            playAgainButton, CommonUI().configureHeaderLabel(title: "OR"), exitButton
        ])
        buttonStack.spacing = 20
        view.addSubview(buttonStack)
        
        view.alpha = 0.9
        view.backgroundColor = .black
    }
    
    func configAutoLayout() {
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    func configButton(title: String, tag: Int, textColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontString, size: 25)
        button.backgroundColor = CommonUI().blackColor
        button.layer.borderWidth = 3.5
        button.layer.borderColor = UIColor(red: 33/255, green: 34/255, blue: 37/255, alpha: 1).cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(textColor, for: .normal)
        if tag == 0 { // play again button
            button.addTarget(self, action: #selector(playAgainAction), for: .touchUpInside)
        } else { // exit button
            button.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        }
        return button
    }
    
    // MARK: - Selectors
    
    @objc func playAgainAction() {
        dismiss(animated: true)
        delegate?.didSelectPlayAgain()
    }
    
    @objc func exitAction() {
        dismiss(animated: true) {
            self.delegate?.didSelectExit()
        }
    }
    
}
