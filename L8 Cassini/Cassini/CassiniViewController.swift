//
//  CassiniViewController.swift
//  Cassini
//
//  Created by CS193p Instructor on 2/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate
{
    // for the UISplitViewControllerDelegate method below to work
    // we have to set ourself as the UISplitViewController's delegate
    // (only we can be that because ImageViewControllers come and goes from the heap)
    // we could probably get away with doing this as late as viewDidLoad
    // but it's a bit safer to do it as early as possible
    // and this is as early as possible
    // (we just came out of the storyboard and "awoke"
    // so we know we are in our UISplitViewController by now)
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }

    // MARK: - Navigation

    // we interpret our segue identifier
    // as a key into the DemoURL.NASA Dictionary (a [String:URL])
    // if we find a URL for that key
    // then we just set the public imageURL of the ImageViewController to it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let url = DemoURL.NASA[segue.identifier ?? ""] {
            if let imageVC = (segue.destination.contents as? ImageViewController) {
                imageVC.imageURL = url
                imageVC.title = (sender as? UIButton)?.currentTitle
            }
        }
    }

    // we "fake out" iOS here
    // this delegate method of UISplitViewController
    // allows the delegate to do the work of collapsing the primary view controller (the master)
    // on top of the secondary view controller (the detail)
    // this happens whenever the split view wants to show the detail
    // but the master is on screen in a spot that would be covered up by the detail
    // the return value of this delegate method is a Bool
    // "true" means "yes, Mr. UISplitViewController, I did collapse that for you"
    // "false" means "sorry, Mr. UISplitViewController, I couldn't collapse so you do it for me"
    // if our secondary (detail) is an ImageViewController with a nil imageURL
    // then we will return true even though we're not actually going to do anything
    // that's because when imageURL is nil, we do NOT want the detail to collapse on top of the master
    // (that's the whole point of this)
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        if primaryViewController.contents == self {
            if let ivc = secondaryViewController.contents as? ImageViewController, ivc.imageURL == nil {
                return true
            }
        }
        return false
    }
}

extension UIViewController
{
    // a friendly var we've added to UIViewController
    // it returns the "contents" of this UIViewController
    // which, if this UIViewController is a UINavigationController
    // means "the UIViewController contained in me (and visible)"
    // otherwise, it just means the UIViewController itself
    // could easily imagine extending this for UITabBarController too
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}






