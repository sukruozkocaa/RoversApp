//
//  OpportunityModel.swift
//  NasaApp
//
//  Created by Şükrü Özkoca on 31.01.2023.
//

import Foundation

struct OSModel: Codable {
    let photos: [OSPhoto]
}

// MARK: - Photo
struct OSPhoto: Codable {
    let id, sol: Int
    let camera: OSCamera
    let imgSrc: String
    let earthDate: String
    let rover: OSRover

    enum CodingKeys: String, CodingKey {
        case id, sol, camera
        case imgSrc = "img_src"
        case earthDate = "earth_date"
        case rover
    }
}

// MARK: - Camera
struct OSCamera: Codable {
    let id: Int
    let name: String
    let roverID: Int
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case roverID = "rover_id"
        case fullName = "full_name"
    }
}

// MARK: - Rover
struct OSRover: Codable {
    let id: Int
    let name, landingDate, launchDate, status: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case landingDate = "landing_date"
        case launchDate = "launch_date"
        case status
    }
}
