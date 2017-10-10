#!/usr/bin/swift

import Foundation

let absolutePath = CommandLine.arguments[1]
let enumerator = FileManager.default.enumerator(atPath:CommandLine.arguments[1])

var deletedFilesCount = 0
while let sourceFileLocation = enumerator?.nextObject() as? String {
    if (sourceFileLocation.hasSuffix(".h") || sourceFileLocation.hasSuffix(".m")) && !sourceFileLocation.contains(".framework") {
        let location = absolutePath + "\(sourceFileLocation)"
        var found = false
        if let string = try? String(contentsOfFile: location, encoding: .utf8) {
            let regex = try? NSRegularExpression(pattern:"@interface\\s*(\\w*?)\\W", options: [])
            let range = NSRange(location:0, length:(string as NSString).length)
            regex?.enumerateMatches(in: string,
                                    options: [],
                                    range: range,
                                    using: { (result, _, _) in
                                        if let result = result {
                                            let value = (string as NSString).substring(with:result.range(at:1))
                                            let enumeratorMatching = FileManager.default.enumerator(atPath:CommandLine.arguments[1])
                                            while let sourceFileLocation = enumeratorMatching?.nextObject() as? String {
                                                if (!sourceFileLocation.hasSuffix(value + ".h") && !sourceFileLocation.hasSuffix(value + ".m")) {
                                                    let locationMatching = absolutePath + sourceFileLocation
                                                    if let string = try? String(contentsOfFile: locationMatching, encoding: .utf8) {
                                                        let regex = try? NSRegularExpression(pattern:value, options: [])
                                                        let range = NSRange(location:0, length:(string as NSString).length)
                                                        regex?.enumerateMatches(in: string,
                                                                                options: [],
                                                                                range: range,
                                                                                using: { (result, _, _) in
                                                                                    found = true
                                                        })
                                                        if found {
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                            if !found {
                                                var headerLocation = location
                                                headerLocation.removeLast()
                                                headerLocation.append("h")
                                                var mainLocation = location
                                                mainLocation.removeLast()
                                                mainLocation.append("m")
                                                if FileManager.default.fileExists(atPath: headerLocation) {
                                                    print("Deleting unused file: " + headerLocation)
                                                    try? FileManager.default.removeItem(atPath: headerLocation)
                                                    deletedFilesCount += 1
                                                }
                                                if FileManager.default.fileExists(atPath: mainLocation) {
                                                    print("Deleting unused file: " + mainLocation)
                                                    try? FileManager.default.removeItem(atPath: mainLocation)
                                                    deletedFilesCount += 1
                                                }
                                            }
                                        }
            })
        }
    }
}
print("Deleted \(deletedFilesCount) unused files")

exit(0)
