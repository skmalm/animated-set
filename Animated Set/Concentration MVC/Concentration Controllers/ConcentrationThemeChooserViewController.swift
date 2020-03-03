//
//  ConcentrationThemeChooserViewController.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/28/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController {

    // MARK: - Properties
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    // MARK: - Methods
    
    @IBAction func themeButtonPressed(_ sender: UIButton) {
        // If a game was started, just change themes rather than segue
        if let cvc = splitViewDetailConcentrationViewController {
            if let theme = Themes.themes[sender.tag] {
                cvc.theme = theme
            }
            // Ensure same behavior on non-split view devices
        } else if let cvc = lastSeguedToConcentrationViewController {
            navigationController?.pushViewController(cvc, animated: true)
            if let theme = Themes.themes[sender.tag] {
                cvc.theme = theme
            }
        } else {
            performSegue(withIdentifier: "showTheme", sender: sender)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        assert(segue.identifier == "showTheme", "Illegal segue from theme chooser to Concentration game")
        if let view = sender as? UIView {
            if let cvc = segue.destination as? ConcentrationViewController {
                if let theme = Themes.themes[view.tag] {
                    cvc.theme = theme
                    lastSeguedToConcentrationViewController = cvc
                }
            }
        }
    }
    

}
