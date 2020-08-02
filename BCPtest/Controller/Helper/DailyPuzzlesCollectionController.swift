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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width*0.46, height: view.frame.width*0.52)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PuzzleCell
        guard let puzzles = puzzles else {return cell}
        let puzzle = puzzles[indexPath.section*2 + indexPath.row]
        cell.configUI(forPuzzle: puzzle)
        cell.label.text = "Difficulty:  " + String(indexPath.section*2 + indexPath.row)
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let puzzles = puzzles else {return}
        delegate?.didSelectPuzzle(puzzle: puzzles[indexPath.section*2 + indexPath.row])
    }
    
}

class PuzzleCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: fontStringLight, size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        addSubview(label)
        
        bc1.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bc1.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bc1.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        //bc1.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.topAnchor.constraint(equalTo: bc1.view.bottomAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
    }
    
    func configAutoLayout() {
        
    }
    
    
}
