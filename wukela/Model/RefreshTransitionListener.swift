//
//  RefreshTransitionListener.swift
//  wukela
//
//  Created by Paulo Custódio on 10/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import Foundation

/*
 Reload a ViewController after dismissing a modally presented view controller
 
 https://stackoverflow.com/questions/28706877/how-can-you-reload-a-viewcontroller-after-dismissing-a-modally-presented-view-co
 */

protocol RefreshTransitionListener {
    func popoverDismissed()
}

class RefreshTransitionMediator {
    /* Singleton */
    class var instance: RefreshTransitionMediator {
        struct Static {
            static let instance: RefreshTransitionMediator = RefreshTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: RefreshTransitionListener?
    
    private init() {}
    
    func setListener(listener: RefreshTransitionListener) {
        self.listener = listener
    }
    
    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}
