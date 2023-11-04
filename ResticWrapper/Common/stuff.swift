import Foundation
import KeychainAccess

func runScript(program: String, repositoryPassword: String) {
  let task = Process()

  task.executableURL = URL(fileURLWithPath: "/bin/bash")
  task.arguments = [program]

  var environmentVariables = [
    "RESTIC_PASSWORD": repositoryPassword
  ]
  for (envVar, value) in ProcessInfo.processInfo.environment {
    if envVar.starts(with: "RESTIC_") || envVar.starts(with: "BACKUP_") {
      environmentVariables[envVar] = value
    }
  }
  task.environment = environmentVariables

  do {
    try task.run()
    task.waitUntilExit()
  } catch {
    print(error.localizedDescription)
  }
}

func getOrSetPassword(itemName: String, accountName: String) -> String? {
  let keychain = Keychain(service: itemName, accessGroup: "de.fnordlab.ResticWrapper")
  var repoPassword = keychain[string: accountName]

  while repoPassword == nil || repoPassword == "" {
    if let enteredPassword = getpass("Enter password for \(itemName): ") {
      repoPassword = String(cString: enteredPassword)
    }

    if let pw = repoPassword {
      keychain[string: accountName] = pw
    }
  }
  return repoPassword
}
