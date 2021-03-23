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
    var fileSize: Int? {
        didSet {
//            let formatter = NumberFormatter()
//            formatter.groupingSeparator = " "
//                    formatter.locale = Locale.current //Locale(identifier: "en_US")
//                    formatter.numberStyle = .decimal
//                    print(formatter.string(from: 5123430)!)
            print(fileSize)
            let bytes = fileSize!.bytes
            let kilobytes = fileSize!.kilobytes
            let megabytes = fileSize!.megabytes
            let gigabytes = fileSize!.gigabytes
            
            print("\(bytes)\t\(kilobytes)\t\(megabytes)\t\(gigabytes)")
            
            var result: String = ""
            var unit: String?
            if (0...999).contains(bytes) {
                result = String(bytes)
                unit = "bytes"
            } else if (0..<1000).contains(Int(kilobytes)) {
                result = String(kilobytes)
                unit = "KB"
            } else if (0..<1000).contains(Int(megabytes)) {
                result = String(megabytes)
                unit = "MB"
            } else {
                result = String(gigabytes)
                unit = "GB"
            }
            self.fileSizeString = result
            self.fileSizeUnit = unit
            print("fileSizeString = \(fileSizeString)")
        }
    }
    var fileSizeString: String?
    var fileSizeUnit: String?
    var mediaType_short: String?
    var mediaType_medium: String? {
        if let mT = mediaType_short {
            let result = kAudioFileFormats[mT, default: AFFD("", "")].medium
            return result
        } else {
            return nil
        }
    }
    
    var mediaType_long: String? {
        if let mT = mediaType_short {
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
    var medium: String
    var long: String
    init(_ short: String, _ long: String) {
        self.medium = short
        self.long = long
    }
}

typealias AFFD = AudioFileFormatDescription

//
// Audio format info from:
// https://wiki.multimedia.cx/
//
let kAudioFileFormats = ["lpcm": AFFD("Linear PCM", """
                            Noncompressed audio data format with one frame per packet.
                            """),
                         "ima4": AFFD("Apple IMA4", """
                            IMA4 file type (associated with ADPCM algorithm by Interactive Multimedia Association) is a cross platform audio compression offering 4:1 compression ratio on 16-bit audio files. In the Windwos world it's known as ADPCM.
                            """),
                         "aac": AFFD("MPEG4 AAC", ""),
                         "MAC3": AFFD("MACE3", ""),
                         "MAC6": AFFD("MACE6", ""),
                         "ulaw": AFFD("ULaw", ""),
                         "alaw": AFFD("ALaw", ""),
                         ".mp1": AFFD("MPEG Layer 1", ""),
                         ".mp2": AFFD("MPEG Layer 2", ""),
                         ".mp3": AFFD("MPEG Layer 3", ""),
                         "alac": AFFD("Apple Lossless", "Audio encoding format developed by Apple for lossless data compression of digital music. Filename extensions: .m4a .caf")
]

let kAcceptedFileFormats = ["wav", /*"mp3", "ogg", */ "aif", "aiff", "m4a"]

extension Int {
    var bytes: Int { self }
    
    //
    //  Binary / IEC Prefixes
    //
    var kibibytes: Double {
        return Double(bytes) / 1_024
    }
    var mebibytes: Double {
        return Double(kibibytes) / 1_024
    }
    var gibibytes: Double {
        return Double(mebibytes) / 1_024
    }
    
    //
    // SI Prefixes
    //
    var kilobytes: Double {
        return Double(bytes) / 1_000
    }
    var megabytes: Double {
        return Double(kilobytes) / 1_000
    }
    var gigabytes: Double {
        return Double(megabytes) / 1_000
    }
}
