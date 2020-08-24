//
//  PostRushController.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/14/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class PostRushController: UIViewController {
    
    // MARK: - Properties
    
    var score : Int!
    var rushMinutes: Int!
    var isBlindfold: Bool!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: PostRushDelegate?
    
    let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: fontString, size: 30)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = CommonUI().greenCorrect
        l.text = "Summary"
        l.alpha = 1
        return l
    }()
    
    let scoreLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: fontString, size: 25)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = .clear
        l.alpha = 1
        return l
    }()
    
    var rankHStack: UIStackView!
    var dayRank: UIView!
    var dayRankValue: Int?
    var weekRank: UIView!
    var weekRankValue: Int?
    var alltimeRank: UIView!
    var alltimeRankValue: Int?
    
    var mainStack: UIStackView!

    var buttonStack: UIStackView!
    var playAgainButton: UIButton!
    var exitButton: UIButton!
    
    // MARK: - Init
    
    init(score: Int, rushMinutes: Int, isBlindfold: Bool) {
        self.score = score
        self.rushMinutes = rushMinutes
        self.isBlindfold = isBlindfold
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRankingStats()
        
        configUI()
        configAutoLayout()
    }
    
    // MARK: - Config
    
    func configUI() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        view.addSubview(blurredEffectView)
        view.addSubview(headerLabel)
        
        scoreLabel.text = "SCORE: \(score!)"
        view.addSubview(scoreLabel)
        dayRank = RankingLabel(rankTitle: "TODAY", rankValue: dayRankValue ?? 0)
        weekRank = RankingLabel(rankTitle: "THIS WEEK", rankValue: weekRankValue ?? 0)
        alltimeRank = RankingLabel(rankTitle: "ALL TIME", rankValue: alltimeRankValue ?? 0)
        rankHStack = CommonUI().configureHStackView(arrangedSubViews: [dayRank, weekRank, alltimeRank])
        rankHStack.distribution = .fillEqually
        
        mainStack = CommonUI().configureStackView(arrangedSubViews: [scoreLabel, rankHStack])
        mainStack.spacing = 20
        view.addSubview(mainStack)
        
        playAgainButton = configButton(title: "Play Again", tag: 0, textColor: CommonUI().greenColor)
        exitButton = configButton(title: "Exit", tag: 1, textColor: CommonUI().redColor)
        buttonStack = CommonUI().configureStackView(arrangedSubViews: [
            playAgainButton, CommonUI().configureHeaderLabel(title: "OR"), exitButton
        ])
        buttonStack.spacing = 20
        view.addSubview(buttonStack)

        view.backgroundColor = .clear
    }
    
    func configAutoLayout() {
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        mainStack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 50).isActive = true
        mainStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mainStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //mainStack.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true

        buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
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
    
    // MARK: - Coredata
    
    func fetchRankingStats() {
        guard let thisUser = Auth.auth().currentUser else {return}
        let predicate = NSPredicate(format: "puzzledUser.uid == %@", thisUser.uid)
        
        var rush3: [Rush3Attempt]
        var rush5: [Rush5Attempt]
        
        let req3 = NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")
        req3.predicate = predicate
        do { rush3 = try context.fetch(req3) }
        catch { print(error); return }
        let req5 = NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")
        req5.predicate = predicate
        do { rush5 = try context.fetch(req5) }
        catch { print(error); return }
        
        let thisDay = Date()
        let thisScore = Int32(score)
        rush3 = rush3.filter{$0.piecesHidden == isBlindfold && $0.timestamp!.hasSame(.year, as: thisDay)}
        rush5 = rush5.filter{$0.piecesHidden == isBlindfold && $0.timestamp!.hasSame(.year, as: thisDay)}
        if rushMinutes == 3 {
            dayRankValue = rush3.filter{ $0.numCorrect > thisScore && $0.timestamp!.hasSame(.day, as: thisDay) }.count + 1
            weekRankValue = rush3.filter{ $0.numCorrect > thisScore && $0.timestamp!.hasSame(.weekOfYear, as: thisDay) }.count + 1
            alltimeRankValue = rush3.filter{ $0.numCorrect > thisScore }.count + 1
        } else if rushMinutes == 5 {
            dayRankValue = rush5.filter{ $0.numCorrect > thisScore && $0.timestamp!.hasSame(.day, as: thisDay) }.count + 1
            weekRankValue = rush5.filter{ $0.numCorrect > thisScore && $0.timestamp!.hasSame(.weekOfYear, as: thisDay) }.count + 1
            alltimeRankValue = rush5.filter{ $0.numCorrect > thisScore }.count + 1
        }
    }
    
}
