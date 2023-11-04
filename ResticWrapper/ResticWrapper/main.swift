//
//  main.swift
//  ResticWrapper
//
//  Created by Andreas Schmitz on 25.10.23.
//

import Foundation
import os

let task = Process()

task.executableURL = URL(fileURLWithPath: "/bin/bash")
task.arguments = ["/Users/aschmitz/bin/restic-backup.sh"]

do {
    try task.run()
    task.waitUntilExit()
} catch {
    print(error.localizedDescription)
}
