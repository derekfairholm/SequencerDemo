//
//  AudioEngine.swift
//  SequencerDemo
//
//  Created by DEREK FAIRHOLM on 6/6/19.
//  Copyright © 2019 DEREK FAIRHOLM. All rights reserved.
//

import AudioKit

class AudioEngine {

    
    // MARK: - This is a type that will allow updating of the ViewController UI in response to MIDI events in the callback
    
    typealias CallbackUpdate = (_ status: UInt8, _ note: UInt8, _ beatPosition: Double) -> Void
    
    var callbackUpdate: CallbackUpdate!
    
    
    // MARK: - Properties
    
    private var sequencer: AKSequencer!
    
    private var mixer: AKMixer!
    
    private var callbackInstrument: AKMIDICallbackInstrument!
    
    private var metronome: AKMIDISampler!
    
 
    // Some of the parameters for the sequence
    
    private var sequenceLength = AKDuration(beats: 4)
    
    private var sequenceTempo: Double = 120.0
    
    
    // MARK: - Initialization
    
    init() {
        
        
        // Initialize AudiKit Components
        
        sequencer = AKSequencer()
        
        mixer = AKMixer()
        
        
        // Initialize the callbackInstrument (sampler) that the sequencer will control
        
        callbackInstrument = AKMIDICallbackInstrument()
        
        // Initialize the sampler that the callbackIntsrument's callback closure will play
        
        metronome = AKMIDISampler()
        
        
        // Plug the samplers into the mixer
        
        
        
        metronome >>> mixer
        
        
        // Set the AudioKit output
        
        AudioKit.output = mixer
    
        
        // Track that the notes for the callback will be written into
        
        if let newTrack = sequencer.newTrack("callback_instrument") {
            newTrack.setMIDIOutput(callbackInstrument.midiIn)
        }
        
        
        // Set callback
        
        callbackInstrument.callback = callback
        
        
        // Setup the sequencer
        
        sequencer.setLength(sequenceLength)
        sequencer.setTempo(sequenceTempo)
        sequencer.enableLooping()
    
        
        //  Load the sound font into the metronome; throw an error if it fails.
        
        do {
            try metronome.loadSoundFont("HS M1 Drums", preset: 0, bank: 0)
        } catch {
            fatalError("Loading Sound Font Failed: \(error.localizedDescription)")
        }
        
        
        // Start AudioKit; throw an error if it fails.
        
        do {
            try AudioKit.start()
        } catch {
            fatalError("Starting AudioKit Failed: \(error.localizedDescription)")
        }
        
    }
    
    
    // MARK: - Helper Methods
    
    private func resetSequencer() {
        
        
        // Stop the sequencer
        
        if sequencer.isPlaying {
            sequencer.stop()
        }
        
        
        // Clear events in the sequencer
        
        for track in sequencer.tracks {
            track.clear()
        }
    }
    
    
    private func callback(_ status: UInt8, _ noteNumber: UInt8, _ velocity: UInt8) {
        
        
        // Update for the View Controller that owns the AudioEngine

        callbackUpdate(status, noteNumber, sequencer.currentPosition.beats)
        
        
        // Respond to MIDI events by playing notes
        
        // 144 is a note on message, 128 note off
        
        if status == 144 {
            try? metronome.play(noteNumber: noteNumber, velocity: velocity, channel: 0)
        } else if status == 128 {
            try? metronome.stop(noteNumber: noteNumber, channel: 0)
        }
    }
    
    func stopSequence() {
        sequencer.stop()
        sequencer.rewind()
    }
}






// MARK: - A function that sets up a quarter-note pulse on the callbackInstrument track

extension AudioEngine {
    
    func quarterNotePulse() {
        
        
        // Stop and clear the sequencer
        
        resetSequencer()
        
        
        // For both tracks in the sequencer, I'm adding one note at each quarter note position in the measure (4 notes)
        
        for quarterNotePosition in 0 ... 3 {
            sequencer.tracks[0].add(noteNumber: MIDINoteNumber(56),
                      velocity: MIDIVelocity(80),
                      position: AKDuration(beats: Double(quarterNotePosition)),
                      duration: AKDuration(beats: 1))
        }
        
        
        // Play the sequence
        
        sequencer.play()
    }
}


// MARK: - A function that sets up an eighth-note pulse on the callbackInstrument track

extension AudioEngine {
    
    func eighthNotePulse() {
        
        
        // Stop and clear the sequencer
        
        resetSequencer()
        
        
        // For both tracks in the sequencer, I'm adding two notes that each last half a beat at each quarter note position in the measure (8 notes)
        
        for quarterNotePosition in 0 ... 3 {
            for eighthNote in 0 ... 1 {
                sequencer.tracks[0].add(noteNumber: MIDINoteNumber(eighthNote == 0 ? 56 : 54),
                          velocity: MIDIVelocity(eighthNote == 0 ? 80 : 40),
                          position: AKDuration(beats: Double(quarterNotePosition) + (eighthNote * 0.5)),
                          duration: AKDuration(beats: 0.5))
            }
        }
        
        // Play the sequence
        
        sequencer.play()
    }
}


