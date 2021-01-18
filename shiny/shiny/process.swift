import Foundation

/// Errors that can occur when executing a command.
public enum ProcessError: Error {
  
  /// Occurs when a process exits with a non-zero termination status.
  case nonZeroReturn(Int32)
  
  /// Occurs if the command returns output that was not encoded in UTF8.
  case unableToDecodeOutput
}

public extension Process {
  
  /// Executes a basic command and returns that command's output.
  /// - parameter args: The command (and arguments) to execute.
  /// - returns: The standard output of the command.
  /// - throws: A `ProcessError` describing what went wrong.
  static func exec(_ args: [String]) throws -> String {
    let process = Process()
    return try process.exec(args)
  }
  
  /// Executes a basic command and returns the command's output.
  /// - parameter args: The command (and arguments) to execute.
  /// - returns: The standard output of the command.
  /// - throws: A `ProcessError` describing what went wrong.
  func exec(_ args: [String]) throws -> String {
    launchPath = "/usr/bin/env"
    arguments = args
    
    let stdout = Pipe()
    standardOutput = stdout
    launch()
    waitUntilExit()
    
    if terminationStatus != 0 {
      throw ProcessError.nonZeroReturn(Int32(terminationStatus))
    }
    
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    if let str = String(data: data, encoding: .utf8) {
      return str
    } else {
      throw ProcessError.unableToDecodeOutput
    }
  }
}
