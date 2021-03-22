//
//  AudioFilePropertyViewer
//
//  Copyright (c) 2021 Alexander Nagel http://www.nagel.pro
//
//  This software includes the "DragView.swift" component created by Geri Borbás:
//
//  - - - - START OF GERI BORBÁS LICENSE - - - - - - - - - - - - - - - - - - - - -
//
//  DragView.swift
//
//  Copyright (c) 2020 Geri Borbás http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  - - - - END OF GERI BORBÁS LICENSE - - - - - - - - - - - - - - - - - - - - -
//



import Foundation
import Cocoa

@objc protocol DragViewDelegate
{
    func dragViewDidReceive(fileURLs: [URL])
}


class DragView: NSView
{
    @IBOutlet weak var delegate: DragViewDelegate?
    
    let fileExtensions = kAcceptedFileFormats
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        color(to: .clear)
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ draggingInfo: NSDraggingInfo) -> NSDragOperation
    {
        var containsMatchingFiles = false
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach
        {
            eachObject in
            if let eachURL = eachObject as? URL
            {
                containsMatchingFiles = containsMatchingFiles || fileExtensions.contains(eachURL.pathExtension.lowercased())
                if containsMatchingFiles {
                    //                    print()
                    //                    print(eachURL.path)
                    //                    print()
                }
            }
        }
        
        switch (containsMatchingFiles)
        {
        case true:
            color(to: .secondaryLabelColor)
            return .copy
        case false:
            color(to: .disabledControlTextColor)
            return .init()
        }
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool
    {
        // Collect URLs.
        var matchingFileURLs: [URL] = []
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach
        {
            eachObject in
            if
                let eachURL = eachObject as? URL,
                fileExtensions.contains(eachURL.pathExtension.lowercased())
            { matchingFileURLs.append(eachURL) }
        }
        
        // Only if any,
        guard matchingFileURLs.count > 0
        else { return false }
        
        // Pass to delegate.
        delegate?.dragViewDidReceive(fileURLs: matchingFileURLs)
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?)
    { color(to: .clear) }
    
    override func draggingEnded(_ sender: NSDraggingInfo)
    { color(to: .clear) }
    
}


extension DragView
{
    func color(to color: NSColor)
    {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
}
