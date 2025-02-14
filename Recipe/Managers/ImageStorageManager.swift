//
//  ImageStorageManager.swift
//  Recipe
//
//  Created by Emma Babayan on 2/12/25.
//

import SwiftUI
import OSLog

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
      Logger.imageStorage.error("Failed to save image: \(fileURL.path), Error: \(error.localizedDescription)")
      throw ImageStorageError.failedToWrite
    }
  }
  
  /// Load UIImage from File System
  func loadImage(fileName: String) async throws -> UIImage {
    let safeFileName = getFileName(from: fileName)
    let fileURL = URL.cachesDirectory.appendingPathComponent(safeFileName)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      Logger.imageStorage.error("File doesn't exist: \(fileURL.path)")
      throw ImageStorageError.fileNotFound
    }
    do {
      let data = try Data(contentsOf: fileURL)
      guard let image = UIImage(data: data) else {
        Logger.imageStorage.error("Invalid image data: \(fileURL.path)")
        throw ImageStorageError.invalidImageData
      }
      return image
    } catch {
      Logger.imageStorage.error("Failed to load image: \(fileURL.path), Error: \(error.localizedDescription)")
      throw error
    }
  }
  
  /// Delete UIImage from File System
  func deleteImage(fileName: String) async throws {
    let safeFileName = getFileName(from: fileName)
    let fileURL = URL.cachesDirectory.appendingPathComponent(safeFileName)
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      Logger.imageStorage.error("File doesn't exist: \(fileURL.path)")
      throw ImageStorageError.fileNotFound
    }
    
    do {
      try FileManager.default.removeItem(at: fileURL)
    } catch {
      Logger.imageStorage.error("Failed to delete image: \(fileURL.path), Error: \(error.localizedDescription)")
      throw ImageStorageError.failedToDelete
    }
  }
  
  /// Getting File name from URL
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

extension Logger {
  static let imageStorage = Logger(subsystem: "com.recipe.imagestorage", category: "FileOperations")
}
