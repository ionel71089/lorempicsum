//
//  ImageListViewController.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import CoreData
import UIKit

class ImageListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var imagePageLoader: ImageDataSource!
    private var fetchController: NSFetchedResultsController<Image>!
    private var diffableDataSource: UITableViewDiffableDataSource<Int, Image>!

    private var imageLoader: ImageLoader!

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePageLoader = App.shared.imagePageLoader
        imageLoader = App.shared.imageLoader
        fetchController = imagePageLoader.repository.makeFetchResultsController()
        fetchController.delegate = self

        setupTableView()

        do {
            try fetchController.performFetch()
            updateSnapshot(animated: false)
        } catch {
            print(error)
        }
    }

    private func setupTableView() {
        diffableDataSource =
            UITableViewDiffableDataSource<Int, Image>(tableView: tableView) { (tableView, indexPath, image) -> UITableViewCell? in
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell

                self.configure(cell: cell, image: image)

                return cell
            }
    }

    private func configure(cell: ImageTableViewCell, image: Image) {
        let (img, future) = imageLoader.getThumbnail(forModel: image)

        let viewModel = ImageCellViewModel(id: image.id!, author: image.author!, image: img) { [weak self] in
            self?.imagePageLoader.didViewItem(at: Int(image.order))
        }
        cell.configure(with: viewModel)

        future?.onSuccess { image in
            if cell.viewModel?.id == viewModel.id {
                cell.photoView.image = image
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! ImageTableViewCell).willDisplay()
    }

    func updateSnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Image>()
        snapshot.appendSections([0])
        snapshot.appendItems(fetchController.fetchedObjects ?? [])
        diffableDataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animated: true)
    }
}
