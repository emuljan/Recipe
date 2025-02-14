//
//  ImageStorageManager.swift
//  Recipe
//
//  Created by Emma Babayan on 2/12/25.
//

import SwiftUI

enum ImageStorageError: Error {
  case invalidImageData
  case fileNotFound
  case failedToWrite
  case failedToDelete
}

actor ImageStorageManager {
  static let shared = ImageStorageManager()
  
  private init() {}
  
  /// Save UIImage to File System (Thread-Safe) - Overwrite if File Exists
  func saveImage(imageData: Data, fileName: String, fileExtension: String = "jpg") async throws -> URL {
    let safeFileName = getFileName(from: fileName)
    let fileURL = URL.cachesDirectory.appendingPathComponent(safeFileName)
  
    do {
      try imageData.write(to: fileURL, options: .atomic)
      return fileURL
    } catch {
      print("Error the file is not writable.", fileURL.path)
      throw ImageStorageError.failedToWrite
    }
  }
  
  /// Load UIImage from File System
  func loadImage(fileName: String) async throws -> UIImage {
    let safeFileName = getFileName(from: fileName)
    let fileURL = URL.cachesDirectory.appendingPathComponent(safeFileName)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw ImageStorageError.fileNotFound
    }
    
    let data = try Data(contentsOf: fileURL)
    guard let image = UIImage(data: data) else {
      throw ImageStorageError.invalidImageData
    }
    return image
  }
  
  /// Delete UIImage from File System
  func deleteImage(fileName: String) async throws {
    let safeFileName = getFileName(from: fileName)
    let fileURL = URL.cachesDirectory.appendingPathComponent(safeFileName)

    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      print("File not found", fileURL.path)
      throw ImageStorageError.fileNotFound
    }
    
    do {
      try FileManager.default.removeItem(at: fileURL)
      print("Successfully deleted image", fileURL.path)
    } catch {
      print("Failed to delete image", error.localizedDescription)
      throw ImageStorageError.failedToDelete
    }
  }
  
  func getFileName(from url: String) -> String {
    guard let urlWithoutQuery = url.split(separator: "?").first?.split(separator: "#").first else {
      return ""
    }
    
    let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
    let fileName = urlWithoutQuery
      .components(separatedBy: allowedCharacters.inverted)
      .joined(separator: "-")
    return fileName
  }
}
