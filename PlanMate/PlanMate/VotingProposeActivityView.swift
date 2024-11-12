//
//  VotingProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Model for ProposeActivity
struct ProposeActivity: Identifiable {
    let id: String
    let title: String
    let groupId: String
    let groupName: String
    let locations: [ProposeLocation]
    let participants: [String]
    let participantNames: [String]
    let status: String
    let createdAt: Date
}

// Model for Location
struct ProposeLocation: Codable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

// Model for VoteSubmission
struct VoteSubmission: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let proposeActivityId: String
    let fromDate: Date
    let toDate: Date
    let comment: String
    let selectedLocation: String
    let submittedAt: Date
}

// ViewModel for VotingProposeActivityView
class VotingProposeActivityViewModel: ObservableObject {
    @Published var proposeActivity: ProposeActivity?
    @Published var voteSubmissions: [VoteSubmission] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var userHasSubmitted = false
    @Published var userSubmission: VoteSubmission?
    @AppStorage("user_name") private var userName: String = ""
    
    private var db = Firestore.firestore()
    
    func fetchProposeActivity(id: String) {
        isLoading = true
        
        db.collection("proposeActivities").document(id).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document,
                      let data = document.data() else {
                    self?.showError = true
                    self?.errorMessage = "Activity not found"
                    return
                }
                
                // Parse locations array
                let locations = (data["locations"] as? [[String: Any]])?.map { locationData in
                    ProposeLocation(
                        name: locationData["name"] as? String ?? "",
                        address: locationData["address"] as? String ?? "",
                        latitude: locationData["latitude"] as? Double ?? 0.0,
                        longitude: locationData["longitude"] as? Double ?? 0.0
                    )
                } ?? []
                
                let proposeActivity = ProposeActivity(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    groupId: data["groupId"] as? String ?? "",
                    groupName: data["groupName"] as? String ?? "",
                    locations: locations,
                    participants: data["participants"] as? [String] ?? [],
                    participantNames: data["participantNames"] as? [String] ?? [],
                    status: data["status"] as? String ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                self?.proposeActivity = proposeActivity
                self?.fetchVoteSubmissions(proposeActivityId: document.documentID)
            }
        }
    }
    
    func fetchVoteSubmissions(proposeActivityId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("voteSubmissions")
            .whereField("proposeActivityId", isEqualTo: proposeActivityId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching vote submissions: \(error)")
                    return
                }
                
                let submissions = snapshot?.documents.map { document -> VoteSubmission in
                    let data = document.data()
                    let submission = VoteSubmission(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        proposeActivityId: data["proposeActivityId"] as? String ?? "",
                        fromDate: (data["fromDate"] as? Timestamp)?.dateValue() ?? Date(),
                        toDate: (data["toDate"] as? Timestamp)?.dateValue() ?? Date(),
                        comment: data["comment"] as? String ?? "",
                        selectedLocation: data["selectedLocation"] as? String ?? "",
                        submittedAt: (data["submittedAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    
                    // Check if this submission belongs to the current user
                    if submission.userId == currentUserId {
                        DispatchQueue.main.async {
                            self?.userHasSubmitted = true
                            self?.userSubmission = submission
                        }
                    }
                    
                    return submission
                } ?? []
                
                DispatchQueue.main.async {
                    self?.voteSubmissions = submissions.filter { $0.userId != currentUserId }
                }
            }
    }
    
    func submitVote(fromDate: Date, toDate: Date, comment: String, selectedLocation: String) {
        guard let currentUser = Auth.auth().currentUser,
              let proposeActivity = proposeActivity else {
            showError = true
            errorMessage = "Unable to submit vote"
            return
        }
        
        let submission = [
            "userId": currentUser.uid,
            "userName": userName,
            "proposeActivityId": proposeActivity.id,
            "fromDate": Timestamp(date: fromDate),
            "toDate": Timestamp(date: toDate),
            "comment": comment,
            "selectedLocation": selectedLocation,
            "submittedAt": Timestamp(date: Date())
        ] as [String : Any]
        
        db.collection("voteSubmissions").addDocument(data: submission) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                self?.userHasSubmitted = true
                self?.userSubmission = VoteSubmission(
                    id: UUID().uuidString,
                    userId: currentUser.uid,
                    userName: self?.userName ?? "",
                    proposeActivityId: proposeActivity.id,
                    fromDate: fromDate,
                    toDate: toDate,
                    comment: comment,
                    selectedLocation: selectedLocation,
                    submittedAt: Date()
                )
                
                // Refresh vote submissions after successful submission
                self?.fetchVoteSubmissions(proposeActivityId: proposeActivity.id)
            }
        }
    }
    
    func deleteSubmission() {
        guard let submissionId = userSubmission?.id else {
            showError = true
            errorMessage = "Cannot find submission to delete"
            return
        }
        
        isLoading = true
        db.collection("voteSubmissions").document(submissionId).delete { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Reset user submission state
                self?.userHasSubmitted = false
                self?.userSubmission = nil
                
                // Refresh submissions list
                if let proposeActivity = self?.proposeActivity {
                    self?.fetchVoteSubmissions(proposeActivityId: proposeActivity.id)
                }
            }
        }
    }
}

struct VotingProposeActivityView: View {
    let proposeActivityId: String
    @StateObject private var viewModel = VotingProposeActivityViewModel()
    @State private var fromDate = Date()
    @State private var toDate = Date()
    @State private var comment = ""
    @State private var selectedLocation = ""
    @State private var showingSubmitAlert = false
    @State private var showLocationError = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        if !viewModel.userHasSubmitted {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Select your availability")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    DateSelectionRow(title: "From", date: $fromDate)
                                    DateSelectionRow(title: "To", date: $toDate)
                                }
                                .padding(.horizontal, 10)
                                
                                TextField("Write a comment (Optional)", text: $comment)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 10)
                                
                                if let activity = viewModel.proposeActivity {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Select your favorite place")
                                            .font(.headline)
                                        
                                        if showLocationError {
                                            Text("Please select a location")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 15) {
                                            ForEach(activity.locations, id: \.name) { location in
                                                LocationSelectionRow(
                                                    location: location.name,
                                                    isSelected: selectedLocation == location.name,
                                                    action: {
                                                        selectedLocation = location.name
                                                        showLocationError = false
                                                    }
                                                )
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                }
                                
                                Button(action: {
                                    if selectedLocation.isEmpty {
                                        showLocationError = true
                                    } else {
                                        showingSubmitAlert = true
                                    }
                                }) {
                                    Text("Submit")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("CustomBlue"))
                                        .foregroundColor(.white)
                                        .cornerRadius(50)
                                        .padding(.horizontal, 30)
                                }
                            }
                        }
                        
                        // Your Submission Section
                        if viewModel.userHasSubmitted, let userSubmission = viewModel.userSubmission {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Your Submission")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingDeleteAlert = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                            Text("Delete")
                                                .foregroundColor(.red)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.red, lineWidth: 1)
                                        )
                                    }
                                }
                                
                                SubmissionCard(submission: userSubmission)
                            }
                            .padding(.bottom, 20)
                        }
                        
                        // Other Submissions List
                        if !viewModel.voteSubmissions.isEmpty {
                            Text(viewModel.userHasSubmitted ? "Other Submitted Members" : "Submitted Members")
                                .font(.headline)
                                .padding(.top)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(viewModel.voteSubmissions) { submission in
                                    SubmissionCard(submission: submission)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.proposeActivity?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingSubmitAlert) {
            Alert(
                title: Text("Submit Vote"),
                message: Text("Are you sure you want to submit your vote?"),
                primaryButton: .default(Text("Submit")) {
                    viewModel.submitVote(
                        fromDate: fromDate,
                        toDate: toDate,
                        comment: comment,
                        selectedLocation: selectedLocation
                    )
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Delete Submission", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteSubmission()
            }
        } message: {
            Text("Are you sure you want to delete your submission? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            viewModel.fetchProposeActivity(id: proposeActivityId)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}


struct DateSelectionRow: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
        }
    }
}

struct LocationSelectionRow: View {
    let location: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? Color("CustomBlue") : .gray)
            Text(location)
                .font(.subheadline)
        }
        .onTapGesture(perform: action)
    }
}

struct SubmissionCard: View {
    let submission: VoteSubmission
    var showDeleteButton: Bool = false
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                Text(submission.userName)
                    .font(.system(size: 18, weight: .semibold))
                
                if showDeleteButton {
                    Spacer()
                    Button(action: {
                        onDelete?()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            if !submission.comment.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "message.fill")
                        .foregroundColor(Color("CustomBlue"))
                    Text(submission.comment)
                        .font(.system(size: 17))
                        .foregroundColor(Color("CustomBlue"))
                        .fontWeight(.medium)
                }
            }
            
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .foregroundColor(Color("CustomBlue"))
                Text(submission.selectedLocation)
                    .font(.system(size: 17))
            }
            
            Text("Available From: \(submission.fromDate.formatted(date: .numeric, time: .omitted)) to: \(submission.toDate.formatted(date: .numeric, time: .omitted))")
                .font(.system(size: 17))
                .foregroundColor(.black)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Preview Provider
struct VotingProposeActivityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VotingProposeActivityView(proposeActivityId: "preview-id")
        }
    }
}
