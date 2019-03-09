//
//  ReviewsInteractor.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation

public typealias FetchCompletion = (Bool, ReviewsError?) -> Void

public protocol ReviewsInteractorProtocol {

    func fetchReviews(completion: FetchCompletion?)

    var numberOfFetchedItems: Int { get }
    var moreItemsAvailable: Bool { get }
    func item(at index: Int) -> ReviewsModel?
}

public class ReviewsInteractor: ReviewsInteractorProtocol {

    private let service: ReviewsServiceProtocol
    private var reviews: ReviewsInfo?
    private var page: Int = 0
    private let pageSize: Int = 15

    init(with service: ReviewsServiceProtocol) {
        self.service = service
    }

    public func fetchReviews(completion: FetchCompletion?) {
        // NOTE: rating, sortBy and direction can be passed from the client interaction in VC. In this case method signature would have those params. Eliminate for now for the simplification
        service.fetchReviews(page: page, pageSize: pageSize, rating: nil, sortBy: nil, direction: nil, retryCount: 1, completion: {  [weak self] reviews, error in
            let r = (self?.reviews?.data ?? []) + (reviews?.data ?? [])
            self?.reviews = reviews
            self?.reviews?.data = r
            completion?(reviews != nil, error)
        })
    }

}

// DataSource access

extension ReviewsInteractor {

    public var numberOfFetchedItems: Int {
        return reviews?.data.count ?? 0
    }

    public var moreItemsAvailable: Bool {
        return page * pageSize < (reviews?.totalReviewsComments ?? 0)
    }

    public func item(at index: Int) -> ReviewsModel? {
        return reviews?.data[index]
    }

}


