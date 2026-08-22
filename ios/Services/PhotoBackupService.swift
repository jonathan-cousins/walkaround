#if canImport(UIKit)
import UIKit
import Photos

public class PhotoBackupService {
    public static let shared = PhotoBackupService()
    
    public func saveToCameraRoll(image: UIImage, metadata: WatermarkMetadata) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized || status == .limited else {
                    continuation.resume(returning: false)
                    return
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, _ in
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
#endif
