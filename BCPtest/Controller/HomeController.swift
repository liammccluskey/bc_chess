//
//  HomeController.swift
//  BCPtest
//
//  Created by Marty McCluskey on 4/30/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

let fontString = "PingFangTC-Semibold"
let fontStringLight = "PingFangTC-Medium"
class HomeController: UIViewController {
    
    // MARK: - Properties
    
    var puzzles: Puzzles! = PuzzlesFromJson().puzzles
    
    let divider1aLabel: UILabel = CommonUI().configureDividerLabel()
    let header1Label: UILabel = {
        let label = UILabel()
        label.text = "BLINDFOLD CHESS PUZZLES"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 25)
        label.backgroundColor = .clear
        return label
    }()
    var divider1Label: UILabel!
    let subheader1label: UILabel = {
        let label = UILabel()
        label.text = "->  CHOOSE PUZZLE TYPE"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: fontString, size: 17)
        label.backgroundColor = .clear
        return label
    }()
    var mate1Button: UIButton!
    var mate2Button: UIButton!
    var mate3Button: UIButton!
    
    let divider2aLabel: UILabel = CommonUI().configureDividerLabel()
    let header2Label: UILabel = {
        let label = UILabel()
        label.text = "AUDIO CHESS PUZZLES"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 25)
        label.backgroundColor = .clear
        return label
    }()
    var divider2Label: UILabel!
    
    let subheader2Label: UILabel = CommonUI().configureSubheaderLabel(title: "FEATURE TO BE RELEASED BY 8/1/20")
    
    var stack1: UIStackView!
    
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureAutoLayout()
    }
    
    // MARK: - Config
    
    func configureUI() {
        configureNavigationBar()
        
        setBackgroundImage()
        
        divider1Label = configureDividerLabel()
        mate1Button = configurePuzzleTypeButton(title: "MATE IN 1")
        mate1Button.addTarget(self, action: #selector(mate1Action), for: .touchUpInside)
        mate2Button = configurePuzzleTypeButton(title: "MATE IN 2")
        mate2Button.addTarget(self, action: #selector(mate2Action), for: .touchUpInside)
        mate3Button = configurePuzzleTypeButton(title: "MATE IN 3")
        mate3Button.addTarget(self, action: #selector(mate3Action), for: .touchUpInside)
        divider2Label = configureDividerLabel()
        stack1 = configureStackView(arrangedSubViews: [
            divider1aLabel,
            header1Label,
            divider1Label,
            subheader1label,
            mate1Button,
            mate2Button,
            mate3Button,
            divider2aLabel,
            header2Label,
            divider2Label,
            subheader2Label
            ])
        stack1.setCustomSpacing(40, after: mate3Button)
        stack1.setCustomSpacing(10, after: header2Label)
        view.addSubview(stack1)
        
        
        view.backgroundColor = .black
    }
    
    func configureAutoLayout() {
        stack1.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        stack1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stack1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "HOME"
    }
    
    func configureStackView(arrangedSubViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.alignment = .fill
        //stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func configurePuzzleTypeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: fontStringLight, size: 20)
        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        //button.layer.borderColor = UIColor(white: 1.0, alpha: 1).cgColor
        button.layer.borderColor = CommonUI().purpleColor.cgColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "nightsky")
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    // MARK: - Selectors
    
    @objc func mate1Action() {
        let controller = PuzzleController(puzzles: puzzles.m1)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func mate2Action() {
        let controller = PuzzleController(puzzles: puzzles.m2)
        navigationController?.pushViewController(controller, animated: true)

    }
    
    @objc func mate3Action() {
        let controller = PuzzleController(puzzles: puzzles.m3)
        navigationController?.pushViewController(controller, animated: true)

    }
    
    // MARK: - UI Helper
    
    func configureDividerLabel() -> UILabel {
        let label = UILabel()
        label.text = "should extend width of the screen"
        label.textColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: fontString, size: 1)
        label.backgroundColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
        return label
    }
}
