//
//  CVResponse.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation

struct CVResponse: Codable {
    let requestId: String
    let metadata: CVMetadata?
    let categories: [CVCategories]?
    let adult: CVAdult?
    let tags: [CVTags]?
    let description: CVDescription?
    let faces: [CVFaces]?
    let color: CVColor?
    let imageType: CVImageType?
    let objects: [CVObjects]?
}

struct CVMetadata: Codable {
    let width: Int?
    let height: Int?
    let format: String?
}

struct CVCategories: Codable {
    let name: String?
    let score: Double?
}

struct CVDetail: Codable {
    let celebrities: [CVCelebrities]?
    let landmarks: [CVLandmarks]?
}

struct CVCelebrities: Codable {
    let name: String?
    let confidence: Double?
    let faceRectangle: CVFaceRectangle?
}

struct CVFaceRectangle: Codable {
    let left: Int?
    let top: Int?
    let width: Int?
    let height: Int?
}

struct CVLandmarks: Codable {
    let name: String?
    let confidence: Double?
}

struct CVAdult: Codable {
    let isAdultContent: Bool?
    let isRacyContent: Bool?
    let adultScore: Double?
    let racyScore: Double?
}

struct CVTags: Codable {
    let name: String?
    let confidence: Double?
}

struct CVDescription: Codable {
    let tags: [String]?
    let captions: [CVCaption]?
}

struct CVCaption: Codable {
    let text: String?
    let confidence: Double?
}

struct CVFaces: Codable {
    let age: Int?
    let gender: String?
    let faceRectangle: CVFaceRectangle?
}

struct CVColor: Codable {
    let dominantColorForeground: String?
    let dominantColorBackground: String?
    let dominantColors: [String]?
    let accentColor: String?
    let isBWImg: Bool?
}

struct CVImageType: Codable {
    let clipArtType: Int?
    let lineDrawingType: Int?
}

struct CVObjects: Codable {
    let rectangle: CVRectangle?
    let object: String?
    let confidence: Double?
}

struct CVRectangle: Codable {
    let x: Int?
    let y: Int?
    let w: Int?
    let h: Int?
}
