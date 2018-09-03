//
//  ProfileViewController.swift
//  ArretadasFGC
//
//  Created by Ada 2018 on 29/08/18.
//  Copyright © 2018 Ada 2018. All rights reserved.
//

import UIKit
import CoreData

class ProfileUserViewController: UIViewController {

    @IBOutlet var stackRoot: UIStackView!
    @IBOutlet var tableView: UITableView!
    
    
    var dbManager = DataManager()
    var user: User?
    var userClubs: [Club] = []
    var icons = ["briefcase", "comment", "location"]
    var info: [String] = []
    var storedOffsets = [Int: CGFloat]()
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = #colorLiteral(red: 0.4390000105, green: 0.4390000105, blue: 0.4390000105, alpha: 1)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.init(width: 3.0, height: 5.0)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        
        return view
    }()
    
    let screenWidth = UIScreen.main.bounds.width
    
	
	override func viewDidLoad() {
		super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileUserTableViewFirstCell", bundle: nil), forCellReuseIdentifier: "cellProfileUser")
        
        //userClubs = user?.clubs?.allObjects as! [Club]
        info = [user?.city ?? "Não Informado", user?.profession ?? "Não Informado", user?.bio ?? "Não Informado" ]
        setupLayout()
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeader()
        setupLayout()
    }
    
    
    func sizeHeader(){
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        var frame = headerView.frame
        frame.size.height = self.view.frame.size.height*0.45
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    func setupLayout(){
        pinBackground(backgroundView, to: stackRoot)
        
        
    }
	
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
    func loadImageFromPath(_ path: String) -> UIImage? {
        
        let fileManager = FileManager.default
        
        if let dir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let imagePath = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(path).path
            return UIImage(contentsOfFile: imagePath)
            
        }
        return nil
        
    }
	
	
}

extension ProfileUserViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user?.expReports?.count ?? 0) + 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfileUser", for: indexPath)
        if indexPath.row == 0 {
            let collection = cell as! ProfileUserTableViewFirstCell
            collection.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            collection.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
            return collection
        }
        //cell dos relatos
//        cell.imageView?.image = UIImage(named: icons[indexPath.row])
//        cell.textLabel?.text = info[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ProfileUserTableViewFirstCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Clubes da luta  que participo"
        }else if section == 1 {
            return "Meus Relatos"
        }
        return ""
        
    }
    
}

extension ProfileUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.clubs?.count ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClubsCollectionViewCell", for: indexPath) as! ClubsCollectionViewCell
        //cell.image.image = self.loadImageFromPath(userClubs[indexPath.row].photo!)
        cell.labelLocal.text = userClubs[indexPath.row].local!
        cell.labelName.text = userClubs[indexPath.row].name!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth*0.21, height: screenWidth*0.21)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 2, bottom: 10, right: 2)
    }
}

extension UIView {
    func addBorder(toEdges edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        func addBorder(toEdge edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
            let border = CALayer()
            border.backgroundColor = color.cgColor
            
            switch edges {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            default:
                break
            }
            
            layer.addSublayer(border)
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(toEdge: .top, color: color, thickness: thickness)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(toEdge: .bottom, color: color, thickness: thickness)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(toEdge: .left, color: color, thickness: thickness)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(toEdge: .right, color: color, thickness: thickness)
        }
    }
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

