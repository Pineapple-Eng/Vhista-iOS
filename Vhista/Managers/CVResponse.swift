//
//  CVResponse.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation

struct CVResponse {
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

struct CVMetadata {
    let width: Int?
    let height: Int?
    let format: String?
}

struct CVCategories {
    let name: String?
    let score: Double?
}

struct CVDetail {
    let celebrities: [CVCelebrities]?
    let landmarks: [CVLandmarks]?
}

struct CVCelebrities {
    let name: String?
    let confidence: Double?
    let faceRectangle: CVFaceRectangle?
}

struct CVFaceRectangle {
    let left: Int?
    let top: Int?
    let width: Int?
    let height: Int?
}

struct CVLandmarks {
    let name: String?
    let confidence: Double?
}

struct CVAdult {
    let isAdultContent: Bool?
    let isRacyContent: Bool?
    let adultScore: Double?
    let racyScore: Double?
}

struct CVTags {
    let name: String?
    let confidence: Double?
}

struct CVDescription {
    let tags: [String]?
    let captions: [CVCaption]?
}

struct CVCaption {
    let text: String?
    let confidence: Double?
}

struct CVFaces {
    let age: Int?
    let gender: String?
    let faceRectangle: CVFaceRectangle?
}

struct CVColor {
    let dominantColorForeground: String?
    let dominantColorBackground: String?
    let dominantColors: [String]?
    let accentColor: String?
    let isBWImg: Bool?
}

struct CVImageType {
    let clipArtType: Int?
    let lineDrawingType: Int?
}

struct CVObjects {
    let rectangle: CVRectangle?
    let object: String?
    let confidence: Double?
}

struct CVRectangle {
    let x: Int?
    let y: Int?
    let w: Int?
    let h: Int?
}
