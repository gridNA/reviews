//
//  ReviewsViewController
//  reviews
//
//  Created by Kateryna Gridina on 07.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import Foundation
import UIKit

protocol ReviewsViewProtocol {

    var presenter: ReviewsPresenterProtocol? { get set }
    func setTitle(_ title: String)
    func showLoadingIndicator(fullScreen: Bool)
    func hideLoadingIndicator()
    func showError(error: ReviewsError?)
    func reloadData()

}

typealias ReviewSetupFunc = (ReviewsInfo?) -> Void

class ReviewsViewController: UIViewController {

    private let reviewsCellIdentifier = String(describing: ReviewViewCell.self)
    var tableView: UITableView!
    // TODO: create a loading indicator
    //private var loadingIndicator: UIView?
    var presenter: ReviewsPresenterProtocol? = nil


    override func viewDidLoad() {
        assert(presenter != nil)
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        presenter?.fetchItems(completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if navigationItem.title == nil, let title = presenter?.numberOfItemsString() {
            // NOTE: should be localized
            setTitle(title)
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.register(UINib(nibName: "ReviewViewCell",
                                 bundle: Bundle(for: ReviewsViewController.self)),
                           forCellReuseIdentifier: "ReviewViewCell")
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }

}

// MARK: - ReviewsViewControllerProtocol

extension ReviewsViewController: ReviewsViewProtocol {

    func setTitle(_ title: String) {
        navigationItem.title = title
    }

    // TODO: implement
    func showLoadingIndicator(fullScreen: Bool) {
        // Better call Soul
    }

    func hideLoadingIndicator() {
        // Hang
    }

    func showError(error: ReviewsError?) {
        // Error handling
    }

    func reloadData() {
        tableView.reloadData()
    }

}

// MARK: - CollectionViewDataSource

extension ReviewsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfFetchedItems ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tmpCell = tableView.dequeueReusableCell(withIdentifier: reviewsCellIdentifier, for: indexPath)
        guard let presenter = presenter, let cell = tmpCell as? ReviewViewCell else { return tmpCell }

        presenter.setupItemView(at: indexPath.item) { viewModel in
            guard let viewModel = viewModel else { return }
            cell.authorLabel.text = viewModel.author
            cell.shortMesageLabel.text = viewModel.message
            cell.titleLabel.text = viewModel.title
        }
        return cell
    }
    
}

// MARK: - CollectionViewDelegate

extension ReviewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectItem(at: indexPath.item)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        presenter?.scrollViewDidScroll(scrollView)
    }

}
