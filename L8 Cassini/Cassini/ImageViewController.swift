//
//  ImageViewController.swift
//  Cassini
//
//  Created by CS193p Instructor on 2/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController
{
    // MARK: Model

    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage()        // then fetch image
            }
        }
    }
    
    // MARK: Private Implementation
    
    // when we dropped this spinner into our storyboard
    // it initially put it as a subview of our scrollView!
    // we used the Document Outline to drag it out to be a sibling of scrollView
    // instead of a subview
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageURL {
            // we're going to start something on another queue soon
            // so let's start a spinner going in the UI to let the user know
            // we'll stop this any time an image actually gets set
            // (we'd never want the spinner and an image appearing at the same time!)
            spinner.startAnimating()
            // try? Data(contentsOf:) blocks the thread it is on
            // we are currently on the main thread
            // so we must dispatch that call off to a background queue
            // we'll use one of the shared, global, concurrent background queues
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                // now that we're back from blocking
                // are we still even interested in this url (i.e. does it == self.imageURL)?
                if let imageData = urlContents, url == self?.imageURL {
                    // now we want to set the image in the UI
                    // but we are not on the main thread right now
                    // so we are not allowed to do UI
                    // no problem: just dispatch the UI stuff back to the main queue
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }

    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we're about to appear on screen so, if needed,
            fetchImage()  // fetch image
        }
    }
    
    // MARK: User Interface

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            // and we must set our minimum and maximum zoom scale
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    fileprivate var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // careful here because scrollView might be nil
            // (for example, if we're setting our image as part of a prepare)
            // so use optional chaining to do nothing
            // if our scrollView outlet has not yet been set
            scrollView?.contentSize = imageView.frame.size
            // now that we've set an image
            // stop any spinner that exists from spinning
            spinner?.stopAnimating()
        }
    }
}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming

extension ImageViewController : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
