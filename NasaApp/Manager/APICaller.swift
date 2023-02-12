//
//  APICaller.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import Foundation
import UIKit

struct Constants {
    let screenSize: CGRect = UIScreen.main.bounds
    
    static let API_KEY = "ZBGxwNTkOJXhcEQjaXPMxok9Bq5cpBmVnjOsHEQu"
    static let baseURL = "https://api.nasa.gov/mars-photos/api/v1/rovers"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    static let shared = APICaller()
    
    func getCuriosityImages(completion: @escaping (Result<[Photo],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/curiosity/photos?sol=1000&api_key=\(Constants.API_KEY)") else {return}
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(Empty.self, from: data)
                completion(.success(photo.photos))
                
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getCameraFilterSpiritPhotos(roverName: String, camera: String, pageNo: Int, completion: @escaping (Result<[OSPhoto],Error>) -> Void ) {
        guard let url = URL(string: "\(Constants.baseURL)/\(roverName)/photos?sol=1000&camera=\(camera)&page=\(pageNo)&api_key=\(Constants.API_KEY)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _ , error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(OSModel.self, from: data)
                completion(.success(photo.photos))
                
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
       
    }
    
    func getCameraFilterPhotos(roverName: String, camera: String, pageNo: Int, completion: @escaping (Result<[Photo],Error>) -> Void ) {
     //   guard let url = "\(Constants.baseURL)spirit/photos?sol=1000&camera=\(camera)&page=\(pageNo)&api_key=\(Constants.API_KEY)" else { return }
        
        guard let url = URL(string: "\(Constants.baseURL)/\(roverName)/photos?sol=1000&camera=\(camera)&page=\(pageNo)&api_key=\(Constants.API_KEY)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _ , error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(Empty.self, from: data)
                completion(.success(photo.photos))
                
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
       
    }
    
    func getOpportunityImages(completion: @escaping (Result<[OSPhoto],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/opportunity/photos?sol=1000&api_key=\(Constants.API_KEY)") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(OSModel.self, from: data)
                completion(.success(results.photos))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getSpiritImages(completion: @escaping (Result<[OSPhoto],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/spirit/photos?sol=1000&api_key=\(Constants.API_KEY)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let results = try JSONDecoder().decode(OSModel.self, from: data)
                completion(.success(results.photos))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
}
