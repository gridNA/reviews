//
//  ReviewsModel.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation

import Foundation

public struct ReviewsModel: Codable {
    var reviewId: Int?
    var rating: String?
    var title: String?
    var message: String?
    var author: String?
    var foreignLanguage: Bool?
    var date: String?
    var dateUnformatted: [String: String]?
    var languageCode: String?
    var travelerType: String?
    var reviewerName: String?
    var reviewerCountry: String?
    var reviewerProfilePhoto: String?
    var isAnonymous: Bool?
    var firstInitial: String?

}

public struct ReviewsInfo: Codable {
    var status: Bool?
    var totalReviewsComments: Int?
    var data: [ReviewsModel] = []
}
