//
//  PopUpViewController.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit
import SDWebImage

class PopUpViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var launchDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var landingDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var dateTaken: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var OSPhotos: [OSPhoto] = [OSPhoto]()
    var photos: [Photo] = [Photo]()
    var index: Int?
    
    init() {
        super.init(nibName: "PopUpViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.addTarget(self, action: #selector(done), for: .allTouchEvents)
        
        if OSPhotos.count != 0{
            let imageURL = URL(string: OSPhotos[index ?? 0].imgSrc)
            imageView.sd_setImage(with: imageURL)
            cameraName.text = "Camera: \( OSPhotos[index ?? 0].camera.name)"
            landingDateLabel.text = "Landing Date: \(OSPhotos[index ?? 0].rover.landingDate)"
            launchDateLabel.text = "Launch Date: \(OSPhotos[index ?? 0].rover.launchDate)"
            statusLabel.text = "Status: \(OSPhotos[index ?? 0].rover.status)"
            dateTaken.text = "Earth Date: \(OSPhotos[index ?? 0].earthDate)"
            vehicleName.text = "Vehicle: \(OSPhotos[index ?? 0].rover.name)"
        }
        else {
            let imageURL = URL(string: photos[index ?? 0].imgSrc)
            imageView.sd_setImage(with: imageURL)
            cameraName.text = "Camera: \( photos[index ?? 0].camera.name)"
            landingDateLabel.text = "Landing Date: \(photos[index ?? 0].rover.landingDate)"
            launchDateLabel.text = "Launch Date: \(photos[index ?? 0].rover.launchDate)"
            statusLabel.text = "Status: \(photos[index ?? 0].rover.status)"
            dateTaken.text = "Earth Date: \(photos[index ?? 0].earthDate)"
            vehicleName.text = "Vehicle: \(photos[index ?? 0].rover.name)"
        }
        
    
        configure()
    }
    
    @objc func done(){
        hide()
    }
    
    func configure(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 10
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: true) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 1, delay: 0.1) {
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        }completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
}
