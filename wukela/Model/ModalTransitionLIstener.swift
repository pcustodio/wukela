//
//  ModalTransitionLIstener.swift
//  wukela
//
//  Created by Paulo Custódio on 12/06/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import Foundation

/*
 Reload a ViewController after dismissing a modally presented view controller
 
 https://stackoverflow.com/questions/28706877/how-can-you-reload-a-viewcontroller-after-dismissing-a-modally-presented-view-co
 */

protocol ModalTransitionListener {
    func modalDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: ModalTransitionListener?
    
    private init() {}
    
    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }
    
    func sendModalDismissed(modelChanged: Bool) {
        listener?.modalDismissed()
    }
}

