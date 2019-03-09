//
//  ReviewsPresenter.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation
import UIKit

typealias ReviewsViewSetupFunc = (ReviewsModel?) -> Void

protocol ReviewsPresenterProtocol {

    func fetchItems(completion: FetchCompletion?)
    func setupItemView(at index: Int, setupFunc: ReviewsViewSetupFunc)
    func numberOfItemsString() -> String
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func ratingStarsFromRating(rating: String?) -> String
    var numberOfFetchedItems: Int { get }
    func selectItem(at index: Int) 

}

class ReviewsPresenter: ReviewsPresenterProtocol {

    private let interactor: ReviewsInteractorProtocol
    private var reviewsView: ReviewsViewProtocol?
    private var wireframe: ReviewsWireframeProtocol?
    private var lastContentYOffset: CGFloat = 0
    private var lastNumberOfFetchedItems: Int = 0

    init(interactor: ReviewsInteractorProtocol, reviewsView: ReviewsViewProtocol, wireframe: ReviewsWireframeProtocol) {
        self.interactor = interactor
        self.reviewsView = reviewsView
        self.wireframe = wireframe
    }

    func fetchItems(completion: FetchCompletion?) {
        if interactor.numberOfFetchedItems == 0 {
            reviewsView?.showLoadingIndicator(fullScreen: false)
        }
        interactor.fetchReviews() { [weak self] success, error in
            guard let strongSelf = self else { return }
            strongSelf.updateScreen(success: success, error: error)
        }
    }

    private func updateScreen(success: Bool, error: ReviewsError?) {
        guard let screen = reviewsView else { return }
        screen.hideLoadingIndicator()
        if success {
            screen.reloadData()
        } else {
            screen.showError(error: error)
        }
    }

    var numberOfFetchedItems: Int {
        return interactor.numberOfFetchedItems
    }

    func numberOfItemsString() -> String {
        // NOTE: string should be localized
        let template = numberOfFetchedItems == 1 ? "Review" : "Reviews"
        let string = String(format: template, arguments: ["\(numberOfFetchedItems)"])
        return string
    }

    func setupItemView(at index: Int, setupFunc: ReviewsViewSetupFunc) {
        setupFunc(interactor.item(at: index))
    }

    func selectItem(at index: Int) {
        guard let nc = (reviewsView as? UIViewController)?.navigationController else { return }
        wireframe?.presentReviewsAlert(review: interactor.item(at: index), navController: nc)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.window != nil else { return }
        fetchMoreItemsIfNeeded(scrollView: scrollView)
    }

    func ratingStarsFromRating(rating: String?) -> String {
        guard let rating = rating else { return "" }
        switch rating {
        case "5.0":
            return "★★★★★"
        case "4.0":
            return "★★★★☆"
        case "3.0":
            return "★★★☆☆"
        case "2.0":
            return "★★☆☆☆"
        default:
            return "★☆☆☆☆"
        }
    }

    private func fetchMoreItemsIfNeeded(scrollView: UIScrollView) {
        guard interactor.moreItemsAvailable, lastNumberOfFetchedItems != interactor.numberOfFetchedItems else { return }
        let showingLastItems = scrollView.contentSize.height - scrollView.contentOffset.y <= 2.0 * scrollView.frame.height
        guard showingLastItems else { return }

        lastNumberOfFetchedItems = interactor.numberOfFetchedItems
        fetchItems(completion: nil)
    }

}
