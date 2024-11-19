//
//  CreateGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins
import PhotosUI
import FirebaseStorage

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var isImagePickerPresented = false
    @State private var isAlertPresented = false
    @State private var alertMessage = ""
    @State private var isQRCodePopupPresented = false
    @State private var groupCode: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @AppStorage("userid") private var userid: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 20) {
                    // Group Image with Edit Icon
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 150)
                        
                        // Selected Image or Default Image
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else {
                            Image("defaultimg")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        }
                        
                        // Photos Picker
                        PhotosPicker(selection: $selectedItem,
                                     matching: .images) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                                     .onChange(of: selectedItem) { newItem in
                                         if let newItem = newItem {
                                             newItem.loadTransferable(type: Data.self) { result in
                                                 switch result {
                                                 case .success(let data):
                                                     if let data = data {
                                                         DispatchQueue.main.async {
                                                             selectedImageData = data
                                                         }
                                                     }
                                                 case .failure(let error):
                                                     print("Error loading image: \(error.localizedDescription)")
                                                 }
                                             }
                                         }
                                     }
                                     .frame(width: 40, height: 40)
                                     .offset(x: -10, y: -10)
                    }
                    .padding(.top, 50)
                    
                    // Group Name TextField
                    TextField("Group Name", text: $groupName)
                        .padding()
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                    
                    // Description TextField
                    TextField("Description (optional)", text: $description)
                        .padding()
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                    
                    // Create Button
                    Button(action: {
                        createGroup()
                    }) {
                        Text("Create")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("CustomBlue"))
                            .cornerRadius(50)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .navigationTitle("Create a Group")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .alert(isPresented: $isAlertPresented) {
                    Alert(title: Text("Required"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $isQRCodePopupPresented) {
                    QRCodePopupView(groupCode: groupCode)
                }
            }
            if isLoading {
                LoadingScreen()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func uploadImage(groupCode: String, completion: @escaping (String?) -> Void) {
        guard let imageData = selectedImageData else {
            completion(nil)
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("group_images/\(groupCode)_\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Compress image
        guard let compressedImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        imageRef.putData(compressedImageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }
    
    private func createGroup() {
        guard !groupName.isEmpty else {
            alertMessage = "Group Name is required"
            isAlertPresented = true
            return
        }
        
        isLoading = true
        groupCode = UUID().uuidString.prefix(8).uppercased()
        
        uploadImage(groupCode: groupCode) { imageURL in
            var groupData: [String: Any] = [
                "groupName": groupName,
                "description": description,
                "groupCode": groupCode,
                "createdBy": userid,
                "members": [userid]
            ]
            
            if let imageURL = imageURL {
                groupData["profileImageURL"] = imageURL
            }
            
            let db = Firestore.firestore()
            db.collection("groups").addDocument(data: groupData) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = "Error creating group: \(error.localizedDescription)"
                        showError = true
                    }
                    return
                }
                
                let userDocRef = db.collection("users").document(userid)
                userDocRef.updateData([
                    "groups": FieldValue.arrayUnion([groupCode])
                ]) { error in
                    DispatchQueue.main.async {
                        isLoading = false
                        
                        if let error = error {
                            errorMessage = "Error updating user: \(error.localizedDescription)"
                            showError = true
                        } else {
                            groupName = ""
                            description = ""
                            isQRCodePopupPresented = true
                        }
                    }
                }
            }
        }
    }
    
}

struct QRCodePopupView: View {
    let groupCode: String
    @State private var isCopied = false
    @State private var isSaveSuccessAlertPresented = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Copy join code or download QR code")
                    .font(.headline)
                
                // Group Code Display with Copy Button
                HStack {
                    Text(groupCode)
                        .font(.system(size: 24, weight: .bold))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button(action: {
                        UIPasteboard.general.string = groupCode
                        isCopied = true
                    }) {
                        Image(systemName: isCopied ? "checkmark.circle" : "doc.on.doc")
                            .font(.system(size: 22))
                            .foregroundColor(isCopied ? .green : .blue)
                    }
                    .padding(.leading, 8)
                }
                
                Divider()
                
                // Download QR Code Button
                Button(action: {
                    saveQRCodeImage()
                }) {
                    HStack {
                        Image(systemName: "qrcode")
                        Text("Download QR Code")
                    }
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("CustomBlue"))
                    .cornerRadius(10)
                }
            }
            .padding()
            .alert(isPresented: $isSaveSuccessAlertPresented) {
                Alert(title: Text("Success"), message: Text("QR Code image saved to Photos"), dismissButton: .default(Text("OK")))
            }
            
            if isLoading {
                LoadingScreen()
            }
        }
    }
    
    // Function to generate and save QR code as an image
    private func saveQRCodeImage() {
        isLoading = true  // Start loading
        let qrCodeImage = generateHighQualityQRCode(from: groupCode)
        
        // Save QR code to the photo library
        let imageSaver = ImageSaver { success in
            isLoading = false
            if success {
                isSaveSuccessAlertPresented = true
            }
        }
        imageSaver.writeToPhotoAlbum(image: qrCodeImage)
    }
    
    // Function to generate a high-quality QR code image from a string
    private func generateHighQualityQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale for higher resolution
        
        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// Helper class for saving image to photo library with a completion handler
class ImageSaver: NSObject {
    private var completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            completion(false)
        } else {
            completion(true)
        }
    }
}

// Loading Overlay View
@ViewBuilder
func LoadingScreen() -> some View {
    ZStack {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
        
        ProgressView()
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
    }
}

// Preview
struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
