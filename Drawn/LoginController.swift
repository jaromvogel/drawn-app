//
//  LoginController.swift
//  Draw!
//
//  Created by Jarom Vogel on 9/4/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import SwiftyJSON

class LoginController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    @IBAction func tappedLogin(sender: UIButton) {
        
        connect().login(emailField.text!, password: passwordField.text!, loginview: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.placeholder = "Email..."
        passwordField.secureTextEntry = true
        passwordField.placeholder = "Password..."
    
    }
    
    
}