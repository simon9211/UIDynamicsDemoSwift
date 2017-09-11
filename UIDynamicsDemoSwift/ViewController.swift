//
//  ViewController.swift
//  UIDynamicsDemoSwift
//
//  Created by xiwang wang on 2017/9/11.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let it: NewtonsCradleView = NewtonsCradleView.init(frame: view.bounds)
        view.addSubview(it)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

