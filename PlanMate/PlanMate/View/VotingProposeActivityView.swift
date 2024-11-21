//
//  VotingProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

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
