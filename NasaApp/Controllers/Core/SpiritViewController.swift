//
//  SpiritViewController.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit

class SpiritViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height:300), collectionViewLayout: layout)
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCollectionViewCell")
        return collectionView
    }()
    
    private var photos: [OSPhoto] = [OSPhoto]()
    private var originalPhotos: [OSPhoto] = [OSPhoto]()
    private var filterPhotos: [OSPhoto] = [OSPhoto]()
    
    private let transparentView = UIView()
    private let tableView = UITableView()
    
    var dataSource = ["NAVCAM","PANCAM"]
    
    var limit = 5
    var totalImages = 0
    var index = 0
    
    var displayImages: [OSPhoto] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .done, target: self, action: #selector(filter))
        view.addSubview(collectionView)
        collectionViewConstraints()
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        fetchSpirit()
    }
    
    private func fetchSpirit() {
        APICaller.shared.getSpiritImages { [weak self] photo in
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
    
    @objc func filter() {
        addTransparentView(frames: CGRect(x: view.frame.width-200, y: 0, width: 200, height: 200))
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
    
    func collectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor,constant: 0),
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        ])
    }
}

extension SpiritViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate{
     
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
        return CGSize(width: collectionView.frame.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       let overLayer = PopUpViewController()
        overLayer.OSPhotos = photos
        overLayer.photos = []
        overLayer.index = indexPath.row
        overLayer.appear(sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == displayImages.count-1 {
            var index = displayImages.count-1
            if index+20 > photos.count-1{
                limit = photos.count-index
            }
            else {
                 limit = index + 20
            }
            while index < limit {
                index += 1
            }
            self.perform(#selector(loadData),with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func loadData() {
        self.collectionView.reloadData()
    }
}

extension SpiritViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        APICaller.shared.getCameraFilterSpiritPhotos(roverName: "spirit",camera: dataSource[indexPath.row], pageNo: 0) { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
                self?.displayImages = photos
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
