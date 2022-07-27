//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = K.appName
        for letter in titleText{//виходить весь цикл проходить за секунду але час додавання букви у кожного різне через різний чарІндекс
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
           }
            charIndex += 1
        }

       
    }
    

}
