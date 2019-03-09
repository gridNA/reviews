//
//  reviewsTests.swift
//  reviewsTests
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import XCTest
import Swinject
@testable import reviews

class MocDependencyContainer {

    public let container = Container()
    public static let instance = DependencyContainer()
}

class reviewsTests: XCTestCase {

    var interactor: ReviewsInteractorProtocol!
    var mockService: ReviewsServiceProtocol!

    let container = MocDependencyContainer.instance.container

    func assemble() {

        container.register(ReviewsInteractorProtocol.self, factory: { r in
            let carService = r.resolve(ReviewsServiceProtocol.self)!
            return ReviewsInteractor(with: carService) }).inObjectScope(.graph)

        container.register(ReviewsServiceProtocol.self,
                           factory: { r in MockReviewsService() }).inObjectScope(.graph)

    }
    
    override func setUp() {
        assemble()
        interactor = MocDependencyContainer.instance.container.resolve(ReviewsInteractorProtocol.self)
        mockService = MocDependencyContainer.instance.container.resolve(ReviewsServiceProtocol.self)
    }

    func test_ifIndexIsOutOfRange_NoItemFound() {
        mockService.fetchReviews(page: 0, pageSize: 20, rating: nil, sortBy: nil, direction: nil, retryCount: 1, completion: { [weak self] reviews, error in
            self?.interactor.reviews = reviews
            XCTAssertNil(self?.interactor.item(at: 25))
        })
    }

    func test_ifPageIsOutRange_NoMoreItemsAvailable() {
        interactor.pageSize = 30
        interactor.page = 0
        mockService.fetchReviews(page: 0, pageSize: interactor.pageSize, rating: nil, sortBy: nil, direction: nil, retryCount: 1, completion: { [weak self] reviews, error in
            self?.interactor.reviews = reviews
            self?.interactor.page = 1
        })
        XCTAssertFalse(interactor.moreItemsAvailable)
    }

}

class MockReviewsService: ReviewsServiceProtocol {

    func fetchReviews(page: Int, pageSize: Int, rating: Int?, sortBy: String?, direction: String?, retryCount: Int, completion: @escaping (Optional<ReviewsInfo>, Optional<ReviewsError>) -> ()) {
        var reviews: ReviewsInfo?
        if let path = Bundle(for: type(of: self)).path(forResource: "ReviewsMocData", ofType: "json") {
            do {
                let response = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                var r = try! decoder.decode(ReviewsInfo.self, from: response)
                let currentChunkIndex = page * pageSize
                r.data = Array(r.data[currentChunkIndex..<currentChunkIndex + pageSize]) 
                reviews = r
                completion(reviews, nil)
            } catch {
                completion(reviews, nil)
            }
        }
    }
}

