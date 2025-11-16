//
//  FeedbackView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import SwiftUI
import Supabase

struct FeedbackView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var feedbackText: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            NavigationStack{
                VStack(spacing: 12) {
                    HStack{
                        VStack(alignment: .leading){
                            Text("First Name")
                                .padding(.bottom, 2)
                                .bold()
                            TextField("Enter your first name...", text: $firstName)
                                .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Last Name")
                                .padding(.bottom, 2)
                                .bold()
                            TextField("Enter your last name...", text: $lastName)
                                .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Email")
                                .padding(.bottom, 2)
                                .bold()
                            TextField("Enter your email...", text: $email)
                                .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Feedback")
                                .padding(.bottom, 2)
                                .bold()
                            TextField("This is the best app ever made...", text: $feedbackText, axis: .vertical)
                                .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await sendFeedback()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Sending..." : "Send Feedback")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(isLoading ? .gray : .blue)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .padding(.bottom)
                    .disabled(isLoading || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                }
                .navigationTitle("Submit Feedback")
                .navigationBarTitleDisplayMode(.inline)
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") {
                        isPresented = false
                    }
                } message: {
                    Text(alertMessage)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @MainActor
    private func sendFeedback() async {
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter your feedback before sending."
            showAlert = true
            return
        }
        
        isLoading = true
        
        do {
            let requestBody = FeedbackRequest(
                name: "\(firstName) \(lastName)",
                email: email,
                role: "user",
                description: feedbackText
            )
            
            try await supabase.functions
                .invoke(
                    "send-feedback",
                    options: FunctionInvokeOptions(
                        body: requestBody
                    )
                )
            
            alertTitle = "Success"
            alertMessage = "Your feedback has been sent successfully!"
            feedbackText = ""
            
        } catch {
            alertTitle = "Error"
            alertMessage = "An unexpected error occurred. Please try again."
            #if DEBUG
            print("Feedback error: \(error)")
            #endif
        }
        
        isLoading = false
        showAlert = true
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let role: String
    let description: String
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        }
    }
}


