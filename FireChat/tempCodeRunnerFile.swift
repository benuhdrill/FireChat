import Foundation
import FirebaseFirestore

@Observable
class MessageManager {

    var messages: [Message] = []
    private let db = Firestore.firestore()

    init(isMocked: Bool = false) {
        if isMocked {
            messages = Message.mockedMessages
        } else {
            // TODO: Fetch messages from Firestore database

        }
    }

    func sendMessage(_ text: String) async {
        let newMessage = Message(
            id: UUID().uuidString,
            text: text,
            username: "", // TODO: Get this from AuthManager
            timestamp: Date()
        )
        
        if let encoded = try? Firestore.Encoder().encode(newMessage) {
            do {
                try await db.collection("messages").document(newMessage.id).setData(encoded)
                messages.append(newMessage)
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }

    // TODO: Save message

    // TODO: Get messages

}
