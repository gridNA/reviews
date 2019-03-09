//
//  ReviewsService.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation
import Alamofire

public typealias CompletionHandler<T, E> = (T, E) -> Void

public enum ReviewsError {
    // NOTE: can be more
    case NoInternetConnectionError
    case UnknowError
}

protocol ReviewsServiceProtocol {

    func fetchReviews(page: Int,
                      pageSize: Int,
                      rating: Int?,
                      sortBy: String?,
                      direction: String?,
                      retryCount: Int,
                      completion: @escaping CompletionHandler<ReviewsInfo?, ReviewsError?>)
}

final class ReviewsService: ReviewsServiceProtocol {

    private enum LanguageCode: String {
        case en = "EN"
        // ...
    }

    private func mainHost(_ language: LanguageCode) -> String {
        switch language {
        case .en:
            return "https://www.getyourguide.com"
        }
    }

    private func reviewsPath(_ language: LanguageCode) -> String {
        switch language {
        case .en:
            return "/berlin-l17/tempelhof-2-hour-airport-history-tour-berlin-airlift-more-t23776/reviews.json"
        }
    }

    private struct Constants {
        static let maxFetchRetryCount = 1
    }

    private var reviewsURLString: String {
        get {
            // Here we check what is an app language. For now is hardcoded
            let appLanguage: LanguageCode = .en
            return "\(mainHost(appLanguage))\(reviewsPath(appLanguage))"
        }
    }

    // MARK:- Mapping logic

    private func reviewsError(error: Error?) -> ReviewsError? {
        if let e = error {
            if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                return ReviewsError.NoInternetConnectionError
            }
            return ReviewsError.UnknowError
        }
        return nil
    }

    // MARK:- Protocol

    func fetchReviews(page: Int,
                      pageSize: Int,
                      rating: Int?,
                      sortBy: String?,
                      direction: String?,
                      retryCount: Int,
                      completion: @escaping CompletionHandler<ReviewsInfo?, ReviewsError?>) {

        Alamofire.request(reviewsURLString,
                          method: .get,
                          parameters: ["page" : page,
                                       "pageSize": pageSize,
                                       "rating": rating,
                                       "sortBy": sortBy,
                                       "direction": direction]).response { [weak self] response in
                                        if let error = response.error {
                                            if retryCount > 0 && retryCount < Constants.maxFetchRetryCount {
                                                self?.fetchReviews(page: page, pageSize: pageSize, rating: rating, sortBy: sortBy, direction: direction, retryCount: retryCount - 1, completion: completion)
                                            } else {
                                                completion(nil, self?.reviewsError(error: error))
                                            }
                                        }
                                        var reviews: ReviewsInfo?
                                        if let data = response.data {
                                            let decoder = JSONDecoder()
                                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                                            reviews = try! decoder.decode(ReviewsInfo.self, from: data)
                                            completion(reviews, self?.reviewsError(error: response.error))
                                        }
        }
        
    }
    
}

