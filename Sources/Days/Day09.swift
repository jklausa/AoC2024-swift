struct Day09: AdventDay {
  var data: String

  enum Block: Hashable {
    case freeSpace(Int)
    case file(length: Int, fileID: Int)

    var length: Int {
      switch self {
      case .file(let length, _):
        return length
      case .freeSpace(let length):
        return length
      }
    }
  }

  func mapDisk(input: String) -> [Block] {
    var fileID = 0

    return input
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .enumerated()
      .compactMap {
      let mappedInt = Int(String($1))!

      if $0 % 2 == 0 {
        let block = Block.file(length: mappedInt, fileID: fileID)
        fileID += 1
        return block
      } else if mappedInt != 0 {
        return Block.freeSpace(mappedInt)
      } else {
        return nil
      }
    }
  }

  func checkSumDisk(input: [Block]) -> Int {
    var currentOffset = 0

    return input.reduce(into: 0) {
      switch $1 {
      case .file(let length, let fileID):
        $0 += Array(currentOffset..<currentOffset+length).reduce(0, +) * fileID

        currentOffset += length
      case .freeSpace(let length):
        currentOffset += length
      }
    }
  }

    func binPackDisk(input: [Block]) -> [Block] {
      var leftPointer = 0
      var disk = input

      while leftPointer < disk.count {
        let itemAtFreeSpaceIndex = disk[leftPointer]

        switch itemAtFreeSpaceIndex {
        case .file:
          leftPointer += 1
          continue
        case .freeSpace(let freeSpaceLength):
          let lastItem = disk.removeLast()

          switch lastItem {
          case .freeSpace:
            // If the last item is a free space, we just yeet it, and retry the loop with the same index, with the new last item.
            continue
          case .file(let lastFileLength, let lastFileID):
            // If it's exactly the same length, we just slot it into place.
            if freeSpaceLength == lastFileLength {
              disk[leftPointer] = lastItem
              leftPointer += 1

              continue
            }

            if freeSpaceLength < lastFileLength {
              // Slot a piece of the file that fits into the free space, append the chunk that didn't fit to the end
              let newItem = Block.file(length: freeSpaceLength, fileID: lastFileID)
              disk[leftPointer] = newItem

              disk.append(Block.file(length: lastFileLength - freeSpaceLength, fileID: lastFileID))
            }

            if freeSpaceLength > lastFileLength {
              disk[leftPointer] = Block.file(length: lastFileLength, fileID: lastFileID)
              disk.insert(.freeSpace(freeSpaceLength - lastFileLength), at: leftPointer + 1)
            }
          }
        }
      }

      return disk
    }


  func part1() -> Any {
    let mappedDisk = mapDisk(input: data)
    let binPackedDisk = binPackDisk(input: mappedDisk)
    let checkSum = checkSumDisk(input: binPackedDisk)

    return checkSum
  }

  func binPackWholeFiles(input: [Block]) -> [Block] {
    var disk = input
    var rightPointer = input.indices.last!

    var movedFileIDs: Set<Int> = []

    while rightPointer > 0 {
      defer {
        rightPointer -= 1
      }

      switch disk[rightPointer] {
      case .freeSpace:
        continue
      case .file(let fileLength, let fileID):
        guard movedFileIDs.contains(fileID) == false else {
          continue
        }

        movedFileIDs.insert(fileID)

        let newIndex = disk.firstIndex(where: {
          guard case let .freeSpace(length) = $0 else { return false }

          return length >= fileLength
        })

        guard let newIndex,
              newIndex < rightPointer else {
          continue
        }

        let spaceLength = disk[newIndex].length
        let newFreeSpace = spaceLength - fileLength

        disk[newIndex] = disk[rightPointer]
        disk[rightPointer] = .freeSpace(fileLength)

        disk.insert(.freeSpace(newFreeSpace), at: newIndex + 1)
        rightPointer += 1
      }
    }

    return disk
  }


  func part2() -> Any {
    let mappedDisk = mapDisk(input: data)
    let wholeFiles = binPackWholeFiles(input: mappedDisk)
    let checksumWholeFiles = checkSumDisk(input: wholeFiles)

    return checksumWholeFiles
  }
}
