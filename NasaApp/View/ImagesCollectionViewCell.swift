//
//  ImagesCollectionViewCell.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import UIKit
import SDWebImage
import Alamofire

protocol refreshCollectionView {
    func refresh()
}

class ImagesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: refreshCollectionView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(date: String) {
        //imageView.image = UIImage(url: URL(string: date))
        /*
        if let url = URL(string: date) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    self.imageView.image = image
                }
            }
        }*/
    
    }
}
