#if canImport(UIKit)
import UIKit

public class ImageStorageService {
    public static let shared = ImageStorageService()
    
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("InspectionPhotos", isDirectory: true)
    }
    
    public init() {
        try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
    }
    
    public func saveImage(_ image: UIImage, filename: String) -> URL? {
        let fileURL = documentsURL.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    public func loadImage(filename: String) -> UIImage? {
        let fileURL = documentsURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    public func deleteImage(filename: String) {
        let fileURL = documentsURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
#endif
