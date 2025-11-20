//
//  EmailListView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import SwiftUI
import Supabase

struct EmailListView: View {
    @Environment(\.colorScheme) var colorScheme

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
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    Text("Subscribe to our email list to stay up to date on all MeetCal LLC products such as MeetCal, CompPrep, and WarGames")
                        .multilineTextAlignment(.center)
                        .padding(.top)
                        .secondaryText()
                        .italic()

                    Spacer()

                    Button(action: {
                        Task {
                            await subscribeToMailingList()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Subscribing..." : "Subscribe")
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
                    .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                }
                .navigationTitle("Join Our Mailing List")
                .navigationBarTitleDisplayMode(.inline)
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") {
                        if alertTitle == "Success" {
                            isPresented = false
                        }
                    }
                } message: {
                    Text(alertMessage)
                }
            }
            .padding(.horizontal)
        }
    }

    @MainActor
    private func subscribeToMailingList() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter your email before subscribing."
            showAlert = true
            return
        }

        // Basic email validation
        guard email.contains("@") && email.contains(".") else {
            alertTitle = "Error"
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }

        isLoading = true

        do {
            let requestBody = MailingListRequest(
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                email: email
            )

            try await supabase.functions
                .invoke(
                    "add-to-mailing-list",
                    options: FunctionInvokeOptions(
                        body: requestBody
                    )
                )

            alertTitle = "Success"
            alertMessage = "You've been successfully added to our mailing list!"
            firstName = ""
            lastName = ""
            email = ""

        } catch {
            alertTitle = "Error"
            if error.localizedDescription.contains("already subscribed") {
                alertMessage = "This email is already subscribed to our mailing list!"
            } else {
                alertMessage = "An unexpected error occurred. Please try again."
            }
            #if DEBUG
            print("Mailing list error: \(error)")
            #endif
        }

        isLoading = false
        showAlert = true
    }
}

struct MailingListRequest: Codable {
    let firstName: String?
    let lastName: String?
    let email: String
}

