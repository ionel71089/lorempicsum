//
//  ImageTableViewCell.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit

struct ImageCellViewModel {
    let id: String
    let author: String
    let image: UIImage?
    let onCellWillDisplay: () -> Void
}

class ImageTableViewCell: UITableViewCell {
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var photoView: UIImageView!

    var viewModel: ImageCellViewModel?

    func configure(with viewModel: ImageCellViewModel) {
        authorLabel.text = viewModel.author
        photoView.image = viewModel.image
        self.viewModel = viewModel
    }

    func willDisplay() {
        viewModel?.onCellWillDisplay()
    }

    override func prepareForReuse() {
        authorLabel.text = nil
        photoView.image = nil
        viewModel = nil
    }
}
