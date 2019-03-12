//
//  Logger.swift
//  RSSReaderSwift
//
//  Created by Debaprio Banik on 3/12/19.
//  Copyright © 2019 Good. All rights reserved.
//

import Foundation

enum LogLevel: Int {
    case Verbose = 0
    case Debug = 1
    case Info = 2
    case Warning = 3
    case Error = 4
}

class Logger {
    private(set) static var shared = Logger()
    private let queue = DispatchQueue.global(qos: .utility)
    private let semaphore = DispatchSemaphore(value: 1)
    private let logFileName = "hearsay-messages.txt"
    
    func log(level: LogLevel, message: String) {
        write("\(Date()) : \(level) : \(message) \n")
        print("\(Date()) : \(level) : \(message)")
    }
    
    private func write(_ string: String) {
        queue.async {
            self.semaphore.wait()
            let log = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(self.logFileName)
            if let handle = try? FileHandle(forWritingTo: log) {
                handle.seekToEndOfFile()
                handle.write(string.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? string.data(using: .utf8)?.write(to: log)
            }
            self.semaphore.signal()
        }
    }
}

