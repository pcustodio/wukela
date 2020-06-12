//
//  TabTransitionListener.swift
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

protocol TabTransitionListener {
    func tabDismissed()
}

class TabTransitionMediator {
    /* Singleton */
    class var instance: TabTransitionMediator {
        struct Static {
            static let instance: TabTransitionMediator = TabTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: TabTransitionListener?
    
    private init() {}
    
    func setListener(listener: TabTransitionListener) {
        self.listener = listener
    }
    
    func sendTabDismissed(modelChanged: Bool) {
        listener?.tabDismissed()
    }
}
