//
//  ProgressController.swift
//  BCPtest
//
//  Created by Guest on 7/31/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProgressController: UIViewController {
    
    // MARK: - Properties
    
    var puzzles: Puzzles! = PuzzlesFromJson().puzzles
    
    
    var currentUser: User!
    var userDBMS: UserDBMS!
    var puzzlesCollection: DailyPuzzlesCollectionController!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDBMS = UserDBMS()
        userDBMS.delegate = self
        userDBMS.getUser(uid: Auth.auth().currentUser!.uid)
    }
    
    // MARK: - Config
    
    func configUI() {
        configNavigationBar()
        
        let flow = UICollectionViewFlowLayout()
        puzzlesCollection = DailyPuzzlesCollectionController(collectionViewLayout: flow)
        puzzlesCollection.delegate = self
        puzzlesCollection.puzzles = puzzles.m3
        puzzlesCollection.collectionView.reloadData()
        view.addSubview(puzzlesCollection.collectionView)
        
        view.backgroundColor = CommonUI().blackColor
    }
    
    func configAutoLayout() {
        puzzlesCollection.collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        puzzlesCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        puzzlesCollection.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        puzzlesCollection.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    func configNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = CommonUI().blackColor
        navigationController?.navigationBar.tintColor = .lightGray
        navigationController?.navigationBar.tintColor = .white
        let font = UIFont(name: fontString, size: 25)
        navigationController?.navigationBar.titleTextAttributes = [.font: font!, .foregroundColor: UIColor.lightGray]
        navigationItem.title = "Your Progress"
    }
}

extension ProgressController: UserDBMSDelegate, DailyPuzzlesCollectionDelegate {
    func sendUser(user: User?) {
        guard let user = user else {return}
        self.currentUser = user
        
        configUI()
        configAutoLayout()
    }
    
    func didSelectPuzzle(puzzle: Puzzle) {
        let controller = DailyPuzzleController(puzzles: [puzzle])
        present(controller, animated: true)
    }
}


