//
//  BeatView.swift
//  SequencerDemo
//
//  Created by DEREK FAIRHOLM on 6/12/19.
//  Copyright © 2019 DEREK FAIRHOLM. All rights reserved.
//

import UIKit

class BeatView: UIView {
    
    
    // MARK: - View Life Cycle
    
    override func didMoveToSuperview() {
        
        setupView()
    }
    
    
    // MARK: - Helper Methods
    
    private func setupView() {
        
        layer.cornerRadius = self.frame.maxY / 2
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
    }
    
    func pulse() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = .darkGray
        }, completion: { _ in
            self.backgroundColor = .lightGray
        })
    }
}

