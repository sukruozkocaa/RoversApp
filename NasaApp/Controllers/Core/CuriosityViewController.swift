//
//  CuriosityViewController.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit

class CuriosityViewController: UIViewController {

    private var photos: [Photo] = [Photo]()
    private var originalPhotos: [Photo] = [Photo]()
    private var filterPhotos: [Photo] = [Photo]()
    private let transparentView = UIView()
    private let tableView = UITableView()
    private var filterCameraName = ""
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Constants().screenSize.width, height: Constants().screenSize.height), collectionViewLayout: layout)
        collectionView.collectionViewLayout = flowLayout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCollectionViewCell")
        return collectionView
    }()
    
    var dataSource = ["ALL","chemcam","fhaz","mast","navcam","rhaz"]
    
    var limit = 5
    var totalImages = 0
    var index = 0
    
    var displayImages: [Photo] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .done, target: self, action: #selector(filter))
        view.addSubview(collectionView)
        collectionViewConstraints()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        fetchCuiosity()
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
    
    @objc func filter() {
        addTransparentView(frames: CGRect(x: view.frame.width-200, y: 0, width: 200, height: 200))
    }
    
    private func fetchCuiosity() {
        APICaller.shared.getCuriosityImages { [weak self] photo in
            switch photo {
            case .success(let photos):
                self?.photos = photos
                self?.originalPhotos = photos
                
                self?.totalImages = photos.count
                
                while self?.index ?? 0 < self?.limit ?? 0 {
                    self?.displayImages.append(photos[self?.index ?? 0])
                    self?.index += 1
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error): break
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor,constant: 0),
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        ])
    }
}

extension CuriosityViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImagesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        cell.configure(date:displayImages[indexPath.row].imgSrc)

        let imageURL = URL(string: displayImages[indexPath.row].imgSrc)
        cell.imageView.sd_setImage(with: imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let overLayer = PopUpViewController()
         overLayer.photos = photos
        overLayer.OSPhotos = []
         overLayer.index = indexPath.row
         overLayer.appear(sender: self)    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == displayImages.count-1 {
            var index = displayImages.count-1
            if index+10 > photos.count-1{
                limit = photos.count-index
            }
            else {
                 limit = index + 10
            }
            while index < limit {
                if self.filterCameraName == "" {
                    displayImages.append(photos[index])
                    index += 1
                }
                else {
                    displayImages = []
                    for i in 0...photos.count-1 {
                        var dataCamera = "\(photos[index].camera.name)"
                        if dataCamera == self.filterCameraName {
                            displayImages.append(photos[index])
                            index += 1
                        }
                    }
                }
            }
            self.perform(#selector(loadData),with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func loadData() {
        self.collectionView.reloadData()
    }
}

extension CuriosityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(dataSource[indexPath.row])"
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
        APICaller.shared.getCameraFilter(roverName: "curiosity", camera: selectCamera, pageNo: 0) { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
                self?.displayImages = photos
                DispatchQueue.main.async {
                    self?.limit = 5
                    self?.totalImages = 0
                    self?.index = 0
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        removeTransparentView()
    }
}
