//
//  FilterDetailViewController.swift
//  Core Image Explorer
//
//  Created by Warren Moore on 1/6/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit

class FilterDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var filterName: String!
    var filter: CIFilter!
    var filteredImageView: FilteredImageView!
    var parameterAdjustmentView: ParameterAdjustmentView!
    var constraints = [NSLayoutConstraint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        filter = CIFilter(name: filterName)
        navigationItem.title = filter.attributes[kCIAttributeFilterDisplayName] as? String

        addSubviews()
    }


    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.barStyle = .black
        tabBarController?.tabBar.barStyle = .black
        applyConstraintsForInterfaceOrientation(interfaceOrientation: UIApplication.shared.statusBarOrientation)
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        applyConstraintsForInterfaceOrientation(interfaceOrientation: toInterfaceOrientation)
    }

    func filterParameterDescriptors() -> [ScalarFilterParameter] {
        let inputNames = (filter.inputKeys).filter { (parameterName) -> Bool in
            return (parameterName as String) != "inputImage"
        }

        let attributes = filter.attributes

        return inputNames.map { (inputName: String) -> ScalarFilterParameter in
            let attribute = attributes[inputName]! as! [String : Any]
            // strip "input" from the start of the parameter name to make it more presentation-friendly
            let displayName = inputName.suffix(from: inputName.index(inputName.startIndex, offsetBy: 5))
            let minValue = attribute[kCIAttributeSliderMin] as! NSNumber
            let maxValue = attribute[kCIAttributeSliderMax] as! NSNumber
            let defaultValue = attribute[kCIAttributeDefault] as! NSNumber

            return ScalarFilterParameter(name: String(displayName), key: inputName,
                                         minimumValue: Float(truncating: minValue), maximumValue: Float(truncating: maxValue), currentValue: Float(truncating: defaultValue))
        }
    }

    func addSubviews() {
        filteredImageView = FilteredImageView(frame: view.bounds)
        filteredImageView.inputImage = UIImage(named: kSampleImageName)
        filteredImageView.filter = filter
        filteredImageView.contentMode = .scaleAspectFit
        filteredImageView.clipsToBounds = true
        filteredImageView.backgroundColor = view.backgroundColor
        filteredImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filteredImageView)

        parameterAdjustmentView = ParameterAdjustmentView(frame: view.bounds, parameters: filterParameterDescriptors())
        parameterAdjustmentView.translatesAutoresizingMaskIntoConstraints = false
        parameterAdjustmentView.setAdjustmentDelegate(delegate: filteredImageView)
        view.addSubview(parameterAdjustmentView)
    }

    func applyConstraintsForInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) {
        view.removeConstraints(constraints)
        constraints.removeAll(keepingCapacity: true)

        if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .width, relatedBy: .equal,
                toItem: view, attribute: .width, multiplier: 0.5, constant: 0))
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .height, relatedBy: .equal,
                toItem: view, attribute: .height, multiplier: 1, constant: -66))
            constraints.append(filteredImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .leading, relatedBy: .equal,
                toItem: view, attribute: .leading, multiplier: 1, constant: 0))

            constraints.append(parameterAdjustmentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .trailing, relatedBy: .equal,
                toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .width, relatedBy: .equal,
                toItem: view, attribute: .width, multiplier: 0.5, constant: 0))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .height, relatedBy: .equal,
                toItem: view, attribute: .height, multiplier: 1, constant: 0))
        } else {
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .width, relatedBy: .equal,
                toItem: view, attribute: .width, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .height, relatedBy: .equal,
                toItem: view, attribute: .height, multiplier: 0.5, constant: 0))
            constraints.append(view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: filteredImageView.topAnchor))
            constraints.append(NSLayoutConstraint(item: filteredImageView, attribute: .leading, relatedBy: .equal,
                toItem: view, attribute: .leading, multiplier: 1, constant: 0))

            constraints.append(parameterAdjustmentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .leading, relatedBy: .equal,
                toItem: view, attribute: .leading, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .width, relatedBy: .equal,
                toItem: view, attribute: .width, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: parameterAdjustmentView, attribute: .height, relatedBy: .equal,
                toItem: view, attribute: .height, multiplier: 0.5, constant: -88))
        }

        self.view.addConstraints(constraints)
    }
}
