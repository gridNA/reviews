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
    func item(at index: Int) -> ReviewsModel?

    var numberOfFetchedItems: Int { get }
    var moreItemsAvailable: Bool { get }
    var reviews: ReviewsInfo? { get set }
    var pageSize: Int { get set }
    var page: Int { get set }
}

public class ReviewsInteractor: ReviewsInteractorProtocol {

    public var pageSize: Int
    private let service: ReviewsServiceProtocol
    public var page: Int = 0
    private var rev: ReviewsInfo?

    init(with service: ReviewsServiceProtocol) {
        self.service = service
        pageSize = 15
    }

    public func fetchReviews(completion: FetchCompletion?) {
        // NOTE: rating, sortBy and direction can be passed from the client interaction in VC. In this case method signature would have those params. Eliminate for now for the simplification
        service.fetchReviews(page: page, pageSize: pageSize, rating: nil, sortBy: nil, direction: nil, retryCount: 1, completion: { [weak self] reviews, error in
            self?.reviews = reviews
            self?.page = self?.page ?? 0 + 1
            completion?(reviews != nil, error)
        })
    }

    public var reviews: ReviewsInfo? {
        get {
            return rev
        }
        set {
            let r = (rev?.data ?? []) + (newValue?.data ?? [])
            rev = newValue
            rev?.data = r
        }
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
        if index > reviews?.data.count ?? 0 - 1 { return nil }
        return reviews?.data[index]
    }

}


