import Foundation
import os

if let repoPassword = getOrSetPassword(
  itemName: "de.fnordlab.ResticWrapper.repository-password", accountName: "repository-password")
{
  let program = "/opt/restic/bin/restic-check.sh"
  runScript(program: program, repositoryPassword: repoPassword)
}
