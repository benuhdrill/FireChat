//
//  AuthManager.swift
//  FireChat
//
//  Created by Ben Gmach on 11/4/24.
//

import Foundation
import FirebaseAuth

@Observable // Ensures the class is observable in SwiftUI or other reactive frameworks
class AuthManager {

    // Stores the logged-in user (provided by FirebaseAuth framework)
    var user: User?
    
    // Determines if `AuthManager` should use mocked data
    let isMocked: Bool

    // Provides the user's email if available, or a mock email if `isMocked` is true
    var userEmail: String? {
        isMocked ? "kingsley@dog.com" : user?.email
    }

    // Track the authentication state listener handle
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    // Initialize with the option to use mocked data
    init(isMocked: Bool = false) {
        self.isMocked = isMocked

        // Check for a cached user when the app starts up
        self.user = Auth.auth().currentUser
        print("Cached user exists: \(self.user != nil)")

        // Add an authentication state listener to update the user and signed-in status
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            print("Auth state changed. User is now: \(user?.email ?? "none")")
        }
    }

    // Remove the authentication state listener when the manager is deinitialized
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Sign up a new user and set the `user` property if successful
    func signUp(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                user = authResult.user
            } catch {
                print("Sign-up error: \(error)")
            }
        }
    }

    // Sign in an existing user and set the `user` property if successful
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                user = authResult.user
            } catch {
                print("Sign-in error: \(error)")
            }
        }
    }

    // Sign out the current user and clear the `user` property
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print("Sign-out error: \(error)")
        }
    }
}
