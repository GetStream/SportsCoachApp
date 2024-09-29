//
//  CustomMessageBubbleModifier.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 27.9.24.
//
import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomMessageBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat = 18
    public var forceLeftToRight = false
    public var topPadding: CGFloat = 0
    public var bottomPadding: CGFloat = 0
    
    @State var id = UUID()
    
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?

    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            if !message.reactionScores.isEmpty {
                CustomReactionsView(
                    message: message,
                    showsAllInfo: false,
                    onTap: withAnimation { onTap } ?? {},
                    onLongPress: withAnimation { onLongPress } ?? {}
                )
                .padding(.all, 8)
            }
        }
        .modifier(
            BubbleModifier(
                corners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                backgroundColors: message.bubbleBackground(
                    colors: colors,
                    injectedBackgroundColor: injectedBackgroundColor
                ),
                cornerRadius: cornerRadius
            )
        )
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .overlay(
            ZStack {
                if message.isSentByCurrentUser {
                    BottomLeftView {
                        overlayContent
                            .offset(x: offsetX)
                    }
                } else {
                    BottomRightView {
                        overlayContent
                            .offset(x: offsetX)
                    }
                }
            }
        )
        .id(id)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: "reactionsUpdated")), perform: { notification in
            if let messageId = notification.userInfo?["messageId"] as? String, messageId == message.id {
                id = UUID()
            }
        })
    }
        
    var offsetX: CGFloat {
        if message.isSentByCurrentUser {
            if isFirst {
                return message.reactionScores.isEmpty ? -74 : -80
            } else {
                return -24
            }
        } else {
            return 54
        }
    }
    
    var overlayContent: some View {
        HStack(spacing: 4) {
            if message.isSentByCurrentUser && isFirst {
                CustomMessageReadIndicatorView(
                    readUsers: Array(message.readBy),
                    showReadCount: false,
                    localState: message.localState
                )
            }
            if isFirst {
                CustomMessageDateView(message: message)
            }
        }
    }
    
}

public struct CustomMessageReadIndicatorView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var readUsers: [ChatUser]
    var showReadCount: Bool
    var localState: LocalMessageState?
    
    public init(readUsers: [ChatUser], showReadCount: Bool, localState: LocalMessageState? = nil) {
        self.readUsers = readUsers
        self.showReadCount = showReadCount
        self.localState = localState
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            Image(
                uiImage: image
            )
            .aspectRatio(contentMode: .fit)
            .frame(height: 16)
            .foregroundColor(!readUsers.isEmpty ? Color.green : Color(colors.textLowEmphasis))
        }
    }
    
    private var image: UIImage {
        !readUsers.isEmpty ? images.readByAll : (localState == .pendingSend ? images.messageReceiptSending : images.messageSent)
    }
}
