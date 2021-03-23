//
//  ViewController.swift
//  AudioFilePropertyViewer
//
//  Created by Alexander Nagel on 21.03.21.
//

import Cocoa
import AVFoundation

//enum AudioError: Error {
//    case noName
//}

class ViewController: NSViewController, DragViewDelegate {
    
    func dragViewDidReceive(fileURLs: [URL]) {
        
        let path = fileURLs[0]
        
        let pathString = path.absoluteString
        
        let filename = pathString.components(separatedBy: "/").last
        
        currentAudioFile.fileName = filename?.removingPercentEncoding
        
        extractAudioInfo(ofFile: path)
        
        updateUI()
        
    }
    
    @IBOutlet weak var dataLabel: NSTextField!
    
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var currentAudioFile = AudioFile(fileName: nil)
    
    //var audioFormat: AVAudioFormat?
    var audioFile: AVAudioFile?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Audio File Property Viewer"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var myFile: AudioFile = AudioFile(fileName: "IEEE float mono 8kHz", fileNameExtension: "wav")
        
        
        
        
        
        updateUI()
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func updateUI() {
        
        let fileSize = currentAudioFile.fileSizeString ?? " "
        let durationSamples = currentAudioFile.durationSamplesString ?? " "
        let durationMS = currentAudioFile.durationMSString ?? " "
        let mediaType = currentAudioFile.mediaType_medium ?? " "
        let mediaTypeDesc = currentAudioFile.mediaType_long ?? " "
        print("XXX\(mediaTypeDesc)")
        let fileName = currentAudioFile.fileName ?? " "
        
        descriptionLabel.stringValue = String("""
            File Name:
            Audio Format:
            File Size:
            Channels:
            Bits per Channel:
            Samplerate:
            Duration:
            Duration:
            Samples:
            Format Description:
            """)
        dataLabel.stringValue = String("""
            \(fileName)
            \(mediaType)
            \(fileSize)
            \(currentAudioFile.channels)
            \(currentAudioFile.bitsPerChannel)
            \(String(format: "%6.0f" ,currentAudioFile.sampleRate)) Hz
            \(durationMS)
            \(durationSamples)
            \(currentAudioFile.lengthInFrames)
            \(mediaTypeDesc)
            """)
    }
    
    
}

extension String {
    
    init(_ fourCharCode: FourCharCode) { // or `OSType`, or `UInt32`
        self = NSFileTypeForHFSTypeCode(fourCharCode).trimmingCharacters(in: CharacterSet(charactersIn: "'"))
    }
    
}

extension ViewController {
    func extractAudioInfo(ofFile audioFileURL: URL) {
        
        //        guard let audioFileURL = Bundle.main.url(forResource: myFile.fileName, withExtension: myFile.fileNameExtension) else {
        //            print("error")
        //            return
        //        }
        
        do {
            audioFile = try AVAudioFile(forReading: audioFileURL)
        } catch let error as NSError  {
            print("error \(error) \(error.description)")
        }
        
        
        //
        // Extract number of channels
        //
        if let channels = audioFile?.fileFormat.channelCount {
            currentAudioFile.channels = channels
        }
        
        //
        // Extract sample rate
        //
        if let rate = audioFile?.fileFormat.sampleRate {
            currentAudioFile.sampleRate = rate
        }
        
        //
        // Extract length in Frames
        //
        if let length = audioFile?.length {
            currentAudioFile.lengthInFrames = length
        }
        
        //
        // Extract bits per channel
        //
        if let bits = CMAudioFormatDescriptionGetStreamBasicDescription(audioFile!.fileFormat.formatDescription)?.pointee.mBitsPerChannel {
            currentAudioFile.bitsPerChannel = bits
        }
        
        //
        // Extract mediaSubType
        // https://developer.apple.com/documentation/coremedia/cmformatdescription/mediasubtype
        //
        if let mediaSubType = audioFile?.fileFormat.formatDescription.mediaSubType  {
            currentAudioFile.mediaType_short = String(mediaSubType.rawValue)
            //print("XXX:\(mediaSubType)")
        }
        
        //
        // Extract file size
        //
        if let fileSize = audioFileURL.fileSize {
            currentAudioFile.fileSize = fileSize
            print("ZZZ:\(fileSize)")
        }
        
        
        // engine.attach(player)
        // engine.connect(player, to: engine.mainMixerNode, format: audioFormat)
        // engine.prepare()
        
        //        do {
        //            try engine.start()
        //        } catch let error as NSError {
        //            //print("error.localizedDescription")
        //            print("error \(error) \(error.description)")
        //        }
        
        
    }
}

public extension URL {

    var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
}
