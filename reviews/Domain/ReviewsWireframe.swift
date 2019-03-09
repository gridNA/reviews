//
//  ReviewsWireframe.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation
import UIKit
import Swinject

protocol ReviewsWireframeProtocol: class {

    func initiateReviewsViewController() -> UINavigationController?
    func presentReviewsAlert(review: ReviewsModel?, navController: UINavigationController)

}

public final class ReviewsWireframe: ReviewsWireframeProtocol {

    private var reviewsView: ReviewsViewProtocol

    init() {
        self.reviewsView = DependencyContainer.instance.container.resolve(ReviewsViewProtocol.self)!
    }

    public func initiateReviewsViewController() -> UINavigationController? {
        reviewsView.presenter = DependencyContainer.instance.container.resolve(ReviewsPresenterProtocol.self, argument: reviewsView)
        guard let viewController = reviewsView as? UIViewController else {
            assertionFailure("screen should be of UIViewController type!")
            return nil
        }
        let vc = UINavigationController(rootViewController: viewController)
        return vc
    }

    public func presentReviewsAlert(review: ReviewsModel?, navController: UINavigationController) {
        let alert = UIAlertController(title: "\(review?.title ?? "")", message: review?.message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        navController.present(alert, animated: true)
    }

}

