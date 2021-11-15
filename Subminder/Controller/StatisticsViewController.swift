//
//  StatisticsViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit
import Lottie

class StatisticsViewController: SUBaseViewController {

    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItems()
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        
        animationView.animationSpeed = 0.5
        
        animationView.play()
    }
    
    private func setupBarItems() {
        
        self.navigationItem.title = "統計"

        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }

}
