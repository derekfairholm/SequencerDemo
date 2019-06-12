//
//  ViewController.swift
//  SequencerDemo
//
//  Created by DEREK FAIRHOLM on 6/3/19.
//  Copyright © 2019 DEREK FAIRHOLM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    // MARK: - State
    
    private enum State {
        case stopped
        case playing
    }
    

    private var state: State = .stopped {
        didSet {
            didSetState(state)
        }
    }
    
    
    // MARK: - AudioEngine
    
    private var audioEngine = AudioEngine()
    
    
    // MARK: - Interface Builder Outlets

    @IBOutlet var quarterNoteViews: [BeatView]!
    
    @IBOutlet var playButtons: [UIButton]!
    
    @IBOutlet weak var stopButton: UIButton! {
        didSet {
            stopButton.isHidden = true
        }
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = "Sequncer position in beats: \n"
        }
    }
    
    
    // MARK: - Properties
    
    private var updateIndex = 0
    
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIUpdate()
    }
    
    
    // MARK: - Interface Builder Actions
    
    @IBAction func didPressQuarterNote(_ sender: Any) {

        state = .playing
        audioEngine.quarterNotePulse()
    }
    
    
    @IBAction func didPressEighthNote(_ sender: Any) {
        
        state = .playing
        audioEngine.eighthNotePulse()
    }
    
    @IBAction func didPressStop(_ sender: Any) {
        state = .stopped
    }
    
    
    // MARK: - Helper Methods
    
    private func setupUIUpdate() {
        
        
        // Here's where I make UI Updates based on MIDI events in the AudioEngine
        
        audioEngine.callbackUpdate = { status, note, beatPosition in
            
            
            // Note on event (144 is a note on message)
            
            if status == 144 {
                
                DispatchQueue.main.async {
                    
                    
                    // print the sequencer position in beats to the textView
                    
                    self.textView.text = self.textView.text + "\n \(beatPosition)"
                    
                    
                    // Scroll to the bottm of the textView if necessary
                    
                    let bottom = NSRange(location: self.textView.text.count - 1, length: 1)
                    self.textView.scrollRangeToVisible(bottom)
                }
                
                
                // Respond only to quarter notes
                
                if note == UInt8(56) {
                    DispatchQueue.main.async {
                        
                        self.quarterNoteViews[self.updateIndex].pulse()
                        
                        if self.updateIndex < self.quarterNoteViews.count - 1 {
                            self.updateIndex += 1
                        } else {
                            self.updateIndex = 0
                        }
                    }
                }
            }
        }
    }
    
    private func didSetState(_ state: State) {
        
        switch state {
        case .stopped:
            
            audioEngine.stopSequence()
            
            updateIndex = 0
            
            for button in playButtons {
                button.isHidden = false
            }
            
            stopButton.isHidden = true
            
        case .playing:
            for button in playButtons {
                button.isHidden = true
            }
            
            stopButton.isHidden = false
            
            textView.text = "Sequncer position in beats: \n"
        }
    }
    
}

