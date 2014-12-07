#!/usr/bin/env xcrun swift

// dict - Make a lookup in Mac OS X's included dictionary. Requires Swift.
//
// Swift rewrite of a MacRuby original by David Kendal ( @dpk )
//
// Run with ./dict.swift or compile with:
//   xcrun --sdk macosx swiftc -o dict dict.swift


import CoreServices
import Foundation

// Construct the help messaged when given a program name.
func helpMessageAs(programName: String) -> String {
    let message = "Usage: \(programName) [options] word ...\n" +
                  "  -h  print these usage instructions"
    return message
}

func errorMessageDataFor(word: String) -> NSData {
    let errorMessage = "dict: no definition for \(word)\n"
    let errorMessageData = errorMessage.dataUsingEncoding(NSUTF8StringEncoding)
    return errorMessageData!
}

// When passed valid input, either print the definition of the word or, if no
// definition for the word is present, print and error stating that.
func printDefinitionFor(word: NSString) {
    let wlen = DCSGetTermRangeInString(nil, word, 0)
    let trimmedWord = word.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    if trimmedWord.isEmpty {
         // do nothing when passed empty string
    } else if wlen.location == -1 {
        let stderr = NSFileHandle.fileHandleWithStandardError()
        stderr.writeData(errorMessageDataFor(trimmedWord))
    } else {
        let wordDefinition = DCSCopyTextDefinition(nil, trimmedWord, wlen).takeUnretainedValue()
        println(wordDefinition)
    }
}

// Handle STDIN.
func input() -> String {
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    let inputString = NSString(data: inputData, encoding:NSUTF8StringEncoding)
    let trimmedString = inputString!.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    return trimmedString
}

// Extract the program name from the arguments, then iterate over the
// arguments to determine what to do.
func run() {
    var arguments = Process.arguments
    // Get program name
    let programName = arguments[0].lastPathComponent
    // Remove program name from argument list
    arguments.removeAtIndex(0)

    if arguments.isEmpty {
        printDefinitionFor(input())
    } else {
        for argument in arguments {
            switch argument {
            case "-h":
                println(helpMessageAs(programName))
            default:
                printDefinitionFor(argument);
            }
        }
    }
}

// Entry point
run()


