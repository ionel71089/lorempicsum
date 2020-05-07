//
//  ImageTableViewCell.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit

struct ImageCellViewModel {
    let author: String
    let onCellWillDisplay: () -> ()
}

class ImageTableViewCell: UITableViewCell {
    @IBOutlet var authorLabel: UILabel!
    private var onCellWillDisplay: (() -> ())?

    func configure(with viewModel: ImageCellViewModel) {
        authorLabel.text = viewModel.author
        onCellWillDisplay = viewModel.onCellWillDisplay
    }

    func willDisplay() {
        onCellWillDisplay?()
    }

    override func prepareForReuse() {
        onCellWillDisplay = nil
    }
}
