//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by CS193p Instructor on 1/30/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class EmotionsViewController: VCLLoggingViewController
{
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let faceViewController = destinationViewController as? FaceViewController,
            let identifier = segue.identifier,
            let expression = emotionalFaces[identifier] {
            faceViewController.expression = expression
            faceViewController.navigationItem.title = (sender as? UIButton)?.currentTitle
        }
    }
    
    private let emotionalFaces: Dictionary<String,FacialExpression> = [
        "sad" : FacialExpression(eyes: .closed, mouth: .frown),
        "happy" : FacialExpression(eyes: .open, mouth: .smile),
        "worried" : FacialExpression(eyes: .open, mouth: .smirk)
    ]
}
