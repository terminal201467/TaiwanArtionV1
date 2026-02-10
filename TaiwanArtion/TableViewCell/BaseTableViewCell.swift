//
//  BaseTableViewCell.swift
//  TaiwanArtion
//
//  Created by Claude on 2024/2/10.
//

import UIKit
import Kingfisher
import RxSwift

/// Base class for all TableViewCells
/// Provides:
/// - Automatic reuseIdentifier
/// - Unified image loading with Kingfisher
/// - Proper prepareForReuse implementation
/// - DisposeBag management for RxSwift
class BaseTableViewCell: UITableViewCell {

    // MARK: - Properties

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    /// DisposeBag for RxSwift subscriptions
    /// Recreated in prepareForReuse to cancel all subscriptions
    var disposeBag = DisposeBag()

    /// Current image loading task (for cancellation)
    private var imageLoadingTask: DownloadTask?

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    /// Override this method to add custom setup
    func setupCell() {
        // Override in subclass
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Cancel any ongoing image loading
        imageLoadingTask?.cancel()
        imageLoadingTask = nil

        // Reset disposeBag to cancel all RxSwift subscriptions
        disposeBag = DisposeBag()

        // Call subclass cleanup
        cleanupForReuse()
    }

    /// Override this method to perform additional cleanup in subclasses
    func cleanupForReuse() {
        // Override in subclass for additional cleanup
    }

    // MARK: - Image Loading

    /// Load image with Kingfisher using standardized options
    /// - Parameters:
    ///   - urlString: The URL string of the image
    ///   - imageView: The UIImageView to load the image into
    ///   - placeholder: Optional placeholder image name (default: "defaultExhibition")
    func loadImage(
        from urlString: String?,
        into imageView: UIImageView,
        placeholder: String = "defaultExhibition"
    ) {
        // Handle empty or placeholder URL
        guard let urlString = urlString,
              !urlString.isEmpty,
              urlString != placeholder,
              let url = URL(string: urlString) else {
            imageView.image = UIImage(named: placeholder)
            return
        }

        imageLoadingTask = imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: placeholder),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .processor(DownsamplingImageProcessor(size: imageView.bounds.size)),
                .scaleFactor(UIScreen.main.scale)
            ]
        ) { [weak self] result in
            if case .failure = result {
                imageView.image = UIImage(named: placeholder)
            }
            self?.imageLoadingTask = nil
        }
    }

    /// Load image with URL directly
    func loadImage(
        from url: URL?,
        into imageView: UIImageView,
        placeholder: String = "defaultExhibition"
    ) {
        guard let url = url else {
            imageView.image = UIImage(named: placeholder)
            return
        }

        loadImage(from: url.absoluteString, into: imageView, placeholder: placeholder)
    }

    // MARK: - Helper Methods

    /// Cancel any ongoing image loading
    func cancelImageLoading() {
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
    }
}
