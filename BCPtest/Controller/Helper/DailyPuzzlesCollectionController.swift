//
//  DailyPuzzlesCollectionController.swift
//  BCPtest
//
//  Created by Guest on 8/1/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class DailyPuzzlesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    let cellID = "cell"
    var puzzles: [Puzzle]?
    var delegate: DailyPuzzlesCollectionDelegate?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        
        collectionView.register(PuzzleCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = .clear
    }
    
    // MARK: - Config
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width*0.3, height: view.frame.width*0.36)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PuzzleCell
        guard let puzzles = puzzles else {return cell}
        let puzzle = puzzles[indexPath.section*2 + indexPath.row]
        cell.configUI(forPuzzle: puzzle)
        cell.difficultyLabel.text = "Difficulty:  " + String(puzzle.solution_moves.count*400 + Int.random(in: 3...200))
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 5, left: 5, bottom: 20, right: 5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let puzzles = puzzles else {return}
        delegate?.didSelectPuzzle(puzzle: puzzles[indexPath.section*2 + indexPath.row])
    }
    
}

class PuzzleCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let difficultyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: fontStringLight, size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let completedImage: UIImageView = {
        let imView = UIImageView()
        imView.translatesAutoresizingMaskIntoConstraints = false
        imView.contentMode = .scaleAspectFit
        imView.image = #imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal)
        return imView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI(forPuzzle puzzle: Puzzle) {
        let bc1 = ChessBoardImageController(position: puzzle.position, boardTheme: .darkBlue)
        bc1.view.translatesAutoresizingMaskIntoConstraints = false
        bc1.view.backgroundColor = .clear
        addSubview(bc1.view)
        
        addSubview(difficultyLabel)
        addSubview(completedImage)
        
        bc1.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bc1.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bc1.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        difficultyLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        difficultyLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        difficultyLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        completedImage.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        completedImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        //completedImage.heightAnchor.constraint(equalToConstant:).isActive = true
        
        
        bc1.view.layer.cornerRadius = 10
        bc1.view.clipsToBounds = true
    }
    
    func configAutoLayout() {
        
    }
    
    
}
