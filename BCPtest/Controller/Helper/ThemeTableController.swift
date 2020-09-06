//
//  ThemeTableController.swift
//  BCPtest
//
//  Created by Guest on 7/27/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//

import UIKit

class ThemeController: UIViewController {
    
    var themeTable: ThemeTableController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Board Theme"
        configUI()
    }
    
    func configUI() {
        themeTable = ThemeTableController(style: .grouped)
        view.addSubview(themeTable.tableView)
        themeTable.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        themeTable.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        themeTable.tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        themeTable.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
}

class ThemeTableController: UITableViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var delegate: ThemeTableDelegate?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = CommonUI().blackColor
        tableView.register(ColorThemeCell.self, forCellReuseIdentifier: colorThemeCellID)
        tableView.register(PieceStyleCell.self, forCellReuseIdentifier: pieceStyleCellID)
    }
    
    // MARK: - Config
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return PieceStyleTheme.allCases.count
        case 1: return ColorTheme.allCases.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return UIScreen.main.bounds.width/2.0/5.0 + 30
        case 1: return UIScreen.main.bounds.width*0.33 + 30
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Select Piece Style"
        case 1: return "Select Board Color Theme"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: pieceStyleCellID, for: indexPath) as! PieceStyleCell
            cell.pieceStyle = indexPath.row
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: colorThemeCellID, for: indexPath) as! ColorThemeCell
            cell.colorTheme = ColorTheme(rawValue: indexPath.row)
            //cell.selectionStyle = .default
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            UserDataManager().setPieceStyle(pieceStyle: indexPath.row)
            pieceStyle = indexPath.row
            break
        case 1: UserDataManager().setBoardColor(boardColor: ColorTheme(rawValue: indexPath.row)!); break
        default: break
        }
    }
}

let colorThemeCellID = "colorThemeCell"
class ColorThemeCell: UITableViewCell {
    
    // MARK: - Init
    
    var colorTheme: ColorTheme! {
        didSet{
            l1.text = colorTheme.description
            boardImage.colorTheme = colorTheme
            boardImage.redrawBlankBoard()
        }
    }
    
    var l1: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont(name: fontString, size: 18)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    var boardImage: ChessBoardImageController!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.colorTheme = ColorTheme(rawValue: 0)!
        configUI()
        configAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Config
    
    func configUI() {
        l1.text = ""
        addSubview(l1)
        let width = UIScreen.main.bounds.width*0.33
        let x = UIScreen.main.bounds.width - width - 15
        let frame = CGRect(x: x, y: 15, width: width, height: width)
        boardImage = ChessBoardImageController(frame: frame, sideLength: width, fen: nil, shouldHidePieces: true, boardTheme: colorTheme)
        addSubview(boardImage.view)
        
        print("\n\n\n\n\n set boardImage origin x as \(boardImage.view.frame.origin.x) and width as \(boardImage.view.frame.width)")
        
        backgroundColor = .clear
        selectionStyle = .gray
    }
    
    func configAutoLayout() {
        l1.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        l1.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

let pieceStyleCellID = "pieceStyleCell"
class PieceStyleCell: UITableViewCell {
    // MARK: - Init
        
    var pieceStyle: Int! {
        didSet {
            print(pieceStyle)
            let theme = PieceStyleTheme(rawValue: pieceStyle)!
            l1.text = theme.description
            let prefix = theme.fileExtension
            let pieceNames = ["wk", "bq", "wr", "bb", "wn", "bp"]
            let pieceIVs = [p1,p2,p3,p4,p5]
            for i in 0..<pieceIVs.count {
                pieceIVs[i]!.image = UIImage(named: prefix + pieceNames[i])
            }

        }
    }
        
    var l1: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont(name: fontString, size: 18)
        l.backgroundColor = .clear
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    var p1: UIImageView! = {
        let iv = UIImageView()
        iv.image = UIImage()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    var p2: UIImageView! = {
        let iv = UIImageView()
        iv.image = UIImage()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    var p3: UIImageView! = {
        let iv = UIImageView()
        iv.image = UIImage()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    var p4: UIImageView! = {
        let iv = UIImageView()
        iv.image = UIImage()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    var p5: UIImageView! = {
        let iv = UIImageView()
        iv.image = UIImage()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    var boardImage: ChessBoardImageController!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.pieceStyle = 0
        configUI()
        configAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Config
    
    func configUI() {
        l1.text = ""
        addSubview(l1)
        let width = UIScreen.main.bounds.width/2.0/5.0
        let xStart = UIScreen.main.bounds.width/2.0
        let ivFrame = CGRect(x: 0, y: 15, width: width, height: width)
        let pieceIVs = [p1,p2,p3,p4,p5]
        for i in 0..<pieceIVs.count {
            pieceIVs[i]!.frame = ivFrame
            pieceIVs[i]!.frame.origin.x = xStart + width*CGFloat(i)
            addSubview(pieceIVs[i]!)
        }
        backgroundColor = .clear
        selectionStyle = .gray
    }
    
    func configAutoLayout() {
        l1.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        l1.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}






