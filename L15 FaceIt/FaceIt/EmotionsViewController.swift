//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by CS193p Instructor on 1/30/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class EmotionsViewController: UITableViewController, UIPopoverPresentationControllerDelegate
{
    // MARK: Model

    // we changed our Model
    // from a Dictionary with keys = emotion names, values = expressions
    // to this Array of tuples with the (name, expression)
    // we also made it a var so we can add new emotions to it
    private var emotionalFaces: [(name: String, expression: FacialExpression)] = [
        ("Sad", FacialExpression(eyes: .closed, mouth: .frown)),
        ("Happy", FacialExpression(eyes: .open, mouth: .smile)),
        ("Worried", FacialExpression(eyes: .open, mouth: .smirk))
    ]

    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emotionalFaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Emotion Cell", for: indexPath)
        cell.textLabel?.text = emotionalFaces[indexPath.row].name
        return cell
    }

    // MARK: - Navigation

    // this is the "special method"
    // we must implement in order to unwind to this MVC
    @IBAction func addEmotionalFace(from segue: UIStoryboardSegue) {
        if let editor = segue.source as? ExpressionEditorViewController {
            emotionalFaces.append((editor.name, editor.expression))
            tableView.reloadData()
        }
    }

    // we support two different kinds of segues
    // the first shows a face when one of our rows is touched on
    // the second is a popover that allows editing and adding a new emotion
    // the only thing we need to do for the second is set ourselves as the popover delegate
    // this is so we can control the "adaptation" behavior
    // (i.e. control how the editor appears if the environment it is in isn't appropriate for a popover)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        // segue to show a face due to a row being chosen
        if let faceViewController = destinationViewController as? FaceViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            faceViewController.expression = emotionalFaces[indexPath.row].expression
            faceViewController.navigationItem.title = emotionalFaces[indexPath.row].name
        // segue to the new emotion editor
        } else if destinationViewController is ExpressionEditorViewController {
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    // in horizontally compact environments
    // popovers by default adapt to be over full screen instead
    // (which is what a modal segue looks like)
    // we want that, but not in the case where it's also vertically compact
    // (that's only the case on iPhones in landscape orientation)
    // in that case, we do NOT want to adapt so we still get a popover

    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle
    {
        if traitCollection.verticalSizeClass == .compact {
            return .none
        } else if traitCollection.horizontalSizeClass == .compact {
            return .overFullScreen
        } else {
            return .none
        }
    }
}
