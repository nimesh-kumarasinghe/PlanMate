//
//  CreateGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var isImagePickerPresented = false
    @State private var groupImage: Image? = Image("defaultimg")
    @State private var isAlertPresented = false
    @State private var alertMessage = ""
    @State private var isQRCodePopupPresented = false
    @State private var groupCode: String = ""
    @State private var isLoading = false  // State for showing loading overlay

    @AppStorage("userid") private var userid: String = ""

    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 20) {
                    // Group Image with Edit Icon
                    ZStack(alignment: .bottomTrailing) {
                        groupImage?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .background(Circle().fill(Color("CustomBlue")))
                            .foregroundColor(.white)
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
                .alert(isPresented: $isAlertPresented) {
                    Alert(title: Text("Required"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    // Implement image picker here
                }
                .sheet(isPresented: $isQRCodePopupPresented) {
                    QRCodePopupView(groupCode: groupCode)
                }
            }

            // Show Loading Overlay if needed
            if isLoading {
                LoadingScreen()
            }
        }
    }

    // Function to validate and create the group in Firestore
    private func createGroup() {
        guard !groupName.isEmpty else {
            alertMessage = "Group Name is required"
            isAlertPresented = true
            return
        }
        
        // Start loading
        isLoading = true

        // Generate a unique code
        groupCode = UUID().uuidString.prefix(8).uppercased()

        // Prepare data for Firestore
        let groupData: [String: Any] = [
            "groupName": groupName,
            "description": description,
            "groupCode": groupCode,
            "createdBy": userid,  // The user who created the group
            "members": [userid]    // Add the current user as a member
        ]

        // Add the group data to Firestore
        let db = Firestore.firestore()
        db.collection("groups").addDocument(data: groupData) { error in
            isLoading = false  // Stop loading
            if let error = error {
                alertMessage = "Error creating group: \(error.localizedDescription)"
                isAlertPresented = true
            } else {
                // Update the user's document in the 'users' collection to include the new group
                let userDocRef = db.collection("users").document(userid)
                userDocRef.updateData([
                    "groups": FieldValue.arrayUnion([groupCode])  // Add the groupCode to the user's groups array
                ]) { error in
                    if let error = error {
                        alertMessage = "Error updating user: \(error.localizedDescription)"
                        isAlertPresented = true
                    } else {
                        // Clear text fields and state variables after successful creation
                        groupName = ""
                        description = ""
                        
                        // Show the QR code popup if creation is successful
                        isQRCodePopupPresented = true
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
    @State private var isLoading = false  // Loading state for saving QR code

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

            // Show Loading Overlay if needed
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
            isLoading = false  // Stop loading
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
