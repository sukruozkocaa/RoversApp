//
//  OpportunityViewController.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit
import SDWebImage

class CellClass: UITableViewCell {
    
}

class OpportunityViewController: UIViewController {

    private var photos: [OSPhoto] = [OSPhoto]()
    private var originalPhotos: [OSPhoto] = [OSPhoto]()
    private var filterPhotos: [OSPhoto] = [OSPhoto]()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height:300), collectionViewLayout: layout)
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCollectionViewCell")
        return collectionView
    }()
    private let transparentView = UIView()
    private let tableView = UITableView()
    var dataSource = ["All","NAVCAM","PANCAM"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .done, target: self, action: #selector(filter))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        fetchOpportunity()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        view.addSubview(transparentView)
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        transparentView.backgroundColor = .black.withAlphaComponent(0.9)
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesure)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0,  usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: self.view.frame.width-200, y: 100, width: 200, height: 200)
        }
    }

    @objc func removeTransparentView() {
        let frames = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIView.animate(withDuration: 0.4, delay: 0.0,  usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }
    }
    
    private func fetchOpportunity() {
        APICaller.shared.getOpportunityImages { [weak self] photo in
            switch photo {
            case .success(let photos):
                self?.photos = photos
                self?.originalPhotos = photos
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func filter(){
        addTransparentView(frames: CGRect(x: view.frame.width-200, y: 0, width: 200, height: 200))
    }
    
    func collectionviewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 0),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor,constant: 0),
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension OpportunityViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImagesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        let imageURL = URL(string: photos[indexPath.row].imgSrc)
        cell.imageView.sd_setImage(with: imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let overLayer = PopUpViewController()
        overLayer.OSPhotos = photos
        overLayer.photos = []
        overLayer.index = indexPath.row
        overLayer.appear(sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 400)
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        let pageWidth:Float = Float(self.view.bounds.width)
        let minSpace:Float = 10.0
        var cellToSwipe:Double = Double(Float((scrollView.contentOffset.x))/Float((pageWidth+minSpace))) + Double(0.5)
        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(self.photos.count) {
            cellToSwipe = Double(self.photos.count) - Double(1)
        }
        let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
        self.collectionView.scrollToItem(at:indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }
}

extension OpportunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectCamera = ""
    
        if indexPath.row == 0 {
            selectCamera = ""
        }
        else {
            selectCamera = "=\(dataSource[indexPath.row])"
        }
        
        APICaller.shared.getOSCameraFilter(roverName: "opportunity",camera:selectCamera, pageNo: 0) { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        removeTransparentView()
    }
}
