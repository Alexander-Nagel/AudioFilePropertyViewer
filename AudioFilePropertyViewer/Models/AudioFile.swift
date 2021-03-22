//
//  AudioFile.swift
//  AudioFilePropertyViewer
//
//  Created by Alexander Nagel on 21.03.21.
//

import Foundation

struct AudioFile {
    var fileName: String?
   // let fileNameExtension: String?
    var mediaType: String?
    var mediaTypeLong: String? {
        if let mT = mediaType {
            let result = kAudioFileFormats[mT, default: AFFD("", "")].short
            return result
        } else {
            return nil
        }
    }
    var mediaTypeDescription: String? {
        if let mT = mediaType {
            let result = kAudioFileFormats[mT, default: AFFD("", "")].long
            return result
        } else {
            return nil
        }
    }
    var durationSamplesString: String? {
        if let hours = duration.hours, let minutes = duration.minutes,
           let seconds = duration.seconds, let samples = duration.samples {
            return(String(format: "%02dh %02dm %02ds %05d samples", hours, minutes, seconds, samples))
        } else {
            return nil
        }
    }
    var durationMSString: String? {
        if let hours = duration.hours, let minutes = duration.minutes,
           let seconds = duration.seconds, let ms = duration.ms {
            return(String(format: "%02dh %02dm %02ds %03dms", hours, minutes, seconds, ms))
        } else {
            return nil
        }
    }
    
    var duration = AudioFileTime()
    var sampleRate: Double = 0
    var lengthInFrames: Int64 = 0 {
        didSet {
            if lengthInFrames != 0 && sampleRate != 0 {
                
                let totalDurationInSeconds: Int = Int(floor ( Double(lengthInFrames) / sampleRate))
                
                secToHMS(secondsIn: totalDurationInSeconds)
                
                let remainingSamples = lengthInFrames % Int64(sampleRate)
                duration.samples = Int(remainingSamples)
                duration.ms = Int(Double(remainingSamples) / sampleRate * 1000)
            }
        }
    }
    var channels: UInt32 = 0
    var bitsPerChannel: UInt32 = 0
  
    mutating func secToHMS (secondsIn: Int) {
        var remainder: Int
        duration.hours = secondsIn / 3600
        remainder = secondsIn % 3600
        duration.minutes = remainder / 60
        remainder = remainder % 60
        duration.seconds = remainder
    }
}

struct AudioFileTime {
    var hours: Int? = 0
    var minutes: Int? = 0
    var seconds: Int? = 0
    var samples: Int? = 0
    var ms: Int? = 0
}

struct AudioFileFormatDescription {
    var short: String
    var long: String
    init(_ short: String, _ long: String) {
        self.short = short
        self.long = long
    }
}

typealias AFFD = AudioFileFormatDescription

let kAudioFileFormats = ["lpcm": AFFD("Linear PCM", """
                            Noncompressed audio data format with one frame per packet.
                            """),
                         "ima4": AFFD("Apple IMA4", ""),
                         "aac": AFFD("MPEG4 AAC", ""),
                         "MAC3": AFFD("MACE3", ""),
                         "MAC6": AFFD("MACE6", ""),
                         "ulaw": AFFD("ULaw", ""),
                         "alaw": AFFD("ALaw", ""),
                         ".mp1": AFFD("MPEG Layer 1", ""),
                         ".mp2": AFFD("MPEG Layer 2", ""),
                         ".mp3": AFFD("MPEG Layer 3", ""),
                         "alac": AFFD("Apple Lossless", "")
]

let kAcceptedFileFormats = ["wav", "mp3", "ogg", "aif", "aiff", "m4a"]
