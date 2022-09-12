//
//  FuzzyMatch.swift
//  ContactsManager
//
//  Created by Ben Lu on 11/09/2022.
//

import Foundation

//public struct Matrix<A> {
//  var array: [A]
//  let width: Int
//  private(set) var height: Int
//  init(width: Int, height: Int, initialValue: A) {
//    array = Array(repeating: initialValue, count: width * height)
//    self.width = width
//    self.height = height
//  }
//
//  private init(width: Int, height: Int, array: [A]) {
//    self.width = width
//    self.height = height
//    self.array = array
//  }
//
//  subscript(column: Int, row: Int) -> A {
//    get { array[row * width + column] }
//    set { array[row * width + column] = newValue }
//  }
//
//  subscript(row row: Int) -> [A] {
//    return Array(array[row * width..<(row + 1) * width])
//  }
//
//  func map<B>(_ transform: (A) -> B) -> Matrix<B> {
//    Matrix<B>(width: width, height: height, array: array.map(transform))
//  }
//
//  mutating func insert(row: [A], at rowIdx: Int) {
//    assert(row.count == width)
//    assert(rowIdx <= height)
//    array.insert(contentsOf: row, at: rowIdx * width)
//    height += 1
//  }
//
//  func inserting(row: [A], at rowIdx: Int) -> Matrix<A> {
//    var copy = self
//    copy.insert(row: row, at: rowIdx)
//    return copy
//  }
//}
//
//extension Array where Element: Equatable {
//  public func fuzzyMatch3(_ needle: [Element]) -> (score: Int, element: Element, matrix: Matrix<Int?>)? {
//    guard needle.count <= count else { return nil }
//    var matrix = Matrix<Int?>(width: self.count, height: needle.count, initialValue: nil)
//    if needle.isEmpty { return (score: 0, element: self, matrix: matrix) }
//    var prevMatchIdx: Int = -1
//    for row in 0..<needle.count {
//      let needleChar = needle[row]
//      var firstMatchIdx: Int?
//      let remainderLength = needle.count - row - 1
//      for column in (prevMatchIdx + 1)..<(count - remainderLength) {
//        let char = self[column]
//        guard needleChar == char else {
//          continue
//        }
//        if firstMatchIdx == nil {
//          firstMatchIdx = column
//        }
//        var score = 1
//        if row > 0 {
//          var maxPrevious = Int.min
//          for prevColumn in prevMatchIdx..<column {
//            guard let s = matrix[prevColumn, row - 1] else { continue }
//            let gapPenalty = (column - prevColumn) - 1
//            maxPrevious = Swift.max(maxPrevious, s - gapPenalty)
//          }
//          score += maxPrevious
//        }
//        matrix[column, row] = score
//      }
//      guard let firstIx = firstMatchIdx else { return nil }
//      prevMatchIdx = firstIx
//    }
//    guard let score = matrix[row: needle.count - 1].compactMap({ $0 }).max() else {
//      return nil
//    }
//    return (score, matrix)
//  }
//}
//extension Array where Element == [UInt8] {
//  public func fuzzyMatch(_ needle: String, getItem: (Element) -> String) -> [(string: [UInt8], element: Element, score: Int)] {
//          let n = Array<UInt8>(needle.utf8)
//    var result: [(string: [UInt8], element: Element, score: Int)] = []
//          let resultQueue = DispatchQueue(label: "result")
//          let cores = ProcessInfo.processInfo.activeProcessorCount
//          let chunkSize = self.count/cores
//          // Note: there is a bug in this code, it's only here to match the episode's contents. Here is the fix: https://github.com/objcio/S01E216-quick-open-optimizing-performance-part-2/pull/2
//          DispatchQueue.concurrentPerform(iterations: cores) { ix in
//              let start = ix * chunkSize
//              let end = Swift.min(start + chunkSize, endIndex)
//              let chunk: [([UInt8], Element, Int)] = self[start..<end].compactMap {
//                  guard let match = $0.fuzzyMatch3(n) else { return nil }
//                return ($0, match.element, match.score)
//              }
//              resultQueue.sync {
//                  result.append(contentsOf: chunk)
//              }
//          }
//          return result
//      }
//}
