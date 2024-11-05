//
//  ChatView.swift
//  FireChat
//
//  Created by Ben Gmach on 11/4/24.
//

import SwiftUI

struct ChatView: View {

    @Environment(AuthManager.self) var authManager
    @State private var messageManager: MessageManager

    init(isMocked: Bool = false) {
        _messageManager = State(initialValue: MessageManager(isMocked: isMocked))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) { // Spacing between messages for a cleaner look
                    ForEach(messageManager.messages) { message in
                        MessageRow(
                            text: message.text,
                            isOutgoing: authManager.userEmail == message.username
                        )
                    }
                }
                .padding(.horizontal) // Horizontal padding around messages
                .padding(.top, 8)
            }
            .defaultScrollAnchor(.bottom) // Scrolls to the bottom by default
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign out") {
                        authManager.signOut()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                SendMessageView { messageText in
                    // TODO: Save message to Firestore
                    messageManager.sendMessage(text: messageText, username: authManager.userEmail ?? "")
                
                }
            }
        }
    }
}

struct MessageRow: View {
    let text: String
    let isOutgoing: Bool

    var body: some View {
        HStack {
            if isOutgoing {
                Spacer()
            }
            messageBubble
            if !isOutgoing {
                Spacer()
            }
        }
        .padding(.horizontal, 10) // Space on both sides of the bubble
    }

    private var messageBubble: some View {
        Text(text)
            .font(.body) // Adjust font size if needed
            .foregroundColor(isOutgoing ? .white : .primary) // Text color based on message type
            .padding(.vertical, 10)
            .padding(.horizontal, 14) // Bubble padding for a compact look
            .background(
                RoundedRectangle(cornerRadius: 18) // Softer corner radius
                    .fill(isOutgoing ? Color.blue : Color(.systemGray5))
            )
            .frame(maxWidth: 300, alignment: isOutgoing ? .trailing : .leading) // Bubble max width and alignment
    }
}

struct SendMessageView: View {
    var onSend: (String) -> Void // <-- Closure called with a message passed in when send message button is tapped

    @State private var messageText: String = "" // <-- Local state managed var to hold the message text as user types

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $messageText, axis: .vertical) // <-- Message text field
                .padding(.leading)
                .padding(.trailing, 4)
                .padding(.vertical, 8)

            // Send message button
            Button {
                onSend(messageText) // <-- Call onSend closure passing in the message text when send button is tapped
                messageText = "" // <-- Clear the message text after being sent
            } label: {
                Image(systemName: "arrow.up.circle.fill") // <-- Use arrow image from SFSymbols
                    .resizable()
                    .frame(width: 30, height: 30)
                    .bold()
                    .padding(4)
            }
            .disabled(messageText.isEmpty) // <-- Disable button if text is empty
        }
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color(uiColor: .systemGray2)))
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thickMaterial) // <-- Add material to background
        //        .focused($isMessageFieldFocused)
    }
}

#Preview {
    ChatView(isMocked: true)
        .environment(AuthManager(isMocked: true))
}
