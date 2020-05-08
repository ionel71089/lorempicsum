//
//  DetailViewController.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    var imageModel: Image
    var imageDownloader: FullImageDownloader

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    init?(coder: NSCoder, image: Image, downloader: FullImageDownloader) {
        self.imageModel = image
        self.imageDownloader = downloader
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.maximumZoomScale = 5.0

        self.title = imageModel.author
        imageDownloader
            .getImage(url: imageModel.downloadUrl!)
            .onSuccess { (image) in
                self.imageView.image = image
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
