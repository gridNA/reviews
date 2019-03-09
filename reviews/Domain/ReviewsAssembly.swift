//
//  ReviewsAssembly.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation
import Swinject

class DependencyContainer {

    public let container = Container()
    public static let instance = DependencyContainer()
}

class ReviewsAssembly {

    let container = DependencyContainer.instance.container

    func assemble() {

        container.register(ReviewsInteractorProtocol.self, factory: { r in
            let carService = r.resolve(ReviewsServiceProtocol.self)!
            return ReviewsInteractor(with: carService) }).inObjectScope(.graph)

        container.register(ReviewsServiceProtocol.self,
                           factory: { r in ReviewsService() }).inObjectScope(.graph)

        container.register(ReviewsPresenterProtocol.self,
                           factory: { (r: Resolver, view: ReviewsViewProtocol) in
                            ReviewsPresenter(interactor: r.resolve(ReviewsInteractorProtocol.self)!,
                                             reviewsView: view,
                                             wireframe: r.resolve(ReviewsWireframeProtocol.self)!
                            ) }).inObjectScope(.graph)

        container.register(ReviewsViewProtocol.self, factory: { _ in
            ReviewsViewController() }).inObjectScope(.graph)

        container.register(ReviewsWireframeProtocol.self,
                           factory: { _ in  ReviewsWireframe() }).inObjectScope(.graph)

    }
}

