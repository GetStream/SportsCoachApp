//
//  CustomReactionsView.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 26.9.24.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI
import Combine

public struct CustomReactionsView: View {
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    
    var showsAllInfo: Bool
    var reactionsPerRow: Int
    var onTap: () -> Void
    var onLongPress: () -> Void
    
    @StateObject var viewModel: ReactionsOverlayViewModel
        
    private let cornerRadius: CGFloat = 16
    private let reactionSize: CGFloat = 16
    
    public init(
        message: ChatMessage,
        showsAllInfo: Bool,
        reactionsPerRow: Int = 4,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) {
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.reactionsPerRow = reactionsPerRow
        self.onLongPress = onLongPress
        _viewModel = StateObject(wrappedValue: ReactionsOverlayViewModel(message: message))
    }
    
    public var body: some View {
        ZStack {
            if reactions.count > 3 {
                let numberOfRows = Int((Double(reactions.count + 1) / Double(reactionsPerRow)).rounded(.up))
                VStack {
                    ForEach(0..<numberOfRows, id: \.self) { row in
                        let start = row * reactionsPerRow
                        let end = start + (reactionsPerRow - 1) >= reactions.count ?
                            reactions.count - 1 : start + (reactionsPerRow - 1)
                        let slice = end < start ? [] : Array(reactions[start...end])
                        let isEndRow = slice.isEmpty ? true : end == (reactions.count - 1)
                        HStack {
                            if message.isRightAligned {
                                Spacer()
                            }
                            content(for: slice, isEndRow: isEndRow)
                            if !message.isRightAligned {
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                HStack {
                    content(for: reactions)
                }
                .offset(y: -2)
            }
        }
    }
    
    private func content(for reactions: [MessageReactionType], isEndRow: Bool = true) -> some View {
        Group {
            ForEach(reactions) { reaction in
                if let image = ReactionsIconProvider.icon(for: reaction, useLargeIcons: false) {
                    HStack(spacing: 4) {
                        ReactionIcon(
                            icon: image,
                            color: ReactionsIconProvider.color(
                                for: reaction,
                                userReactionIDs: userReactionIDs
                            )
                        )
                        .frame(width: reactionSize + 8, height: reactionSize)
                        Text("\(count(for: reaction))")
                    }
                    .animation(nil)
                    .padding(.all, 6)
                    .padding(.horizontal, 2)
                    .background(userReactionIDs.contains(reaction) ? Color.customBlue.opacity(0.3) : Color(colors.background1))
                    .modifier(
                        BubbleModifier(
                            corners: corners(for: reaction, in: reactions, isEndRow: isEndRow),
                            backgroundColors: [Color(colors.background1)],
                            cornerRadius: cornerRadius
                        )
                    )
                    .onTapGesture {
                        viewModel.reactionTapped(reaction)
                    }
                    .onLongPressGesture {
                        onLongPress()
                    }
                }
            }
            
            if isEndRow && reactions.count < reactionsPerRow {
                Button(
                    action: onTap,
                    label: {
                        Image(systemName: "face.smiling")
                            .overlay(
                                TopRightView {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 6)
                                        .padding(.all, 2)
                                        .background(Color(colors.background1))
                                        .clipShape(Circle())
                                        .offset(x: 4, y: -3)
                                }
                            )
                            .padding(.all, 6)
                            .padding(.horizontal, 4)
                            .modifier(
                                BubbleModifier(
                                    corners: cornersForAddReactionButton,
                                    backgroundColors: [Color(colors.background1)],
                                    cornerRadius: cornerRadius
                                )
                            )
                            .foregroundColor(.gray)
                    }
                )
            }
        }
    }
    
    private var message: ChatMessage {
        viewModel.message
    }
    
    private var reactions: [MessageReactionType] {
        viewModel.reactions
    }
    
    private var cornersForAddReactionButton: UIRectCorner {
        (message.isSentByCurrentUser && showsAllInfo) ?
            [.bottomLeft, .bottomRight, .topLeft] : .allCorners
    }
    
    private func corners(
        for reaction: MessageReactionType,
        in reactions: [MessageReactionType],
        isEndRow: Bool
    ) -> UIRectCorner {
        if message.isSentByCurrentUser || reaction != reactions.first || !showsAllInfo {
            return .allCorners
        }
        if isEndRow {
            return [.bottomLeft, .bottomRight, .topRight]
        } else {
            return .allCorners
        }
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
    
    private func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
}

class ReactionsIconProvider {
    static var colors: ColorPalette = InjectedValues[\.colors]
    static var images: Images = InjectedValues[\.images]
    
    static func icon(for reaction: MessageReactionType, useLargeIcons: Bool) -> UIImage? {
        if useLargeIcons {
            return images.availableReactions[reaction]?.largeIcon
        } else {
            return images.availableReactions[reaction]?.smallIcon
        }
    }

    static func color(for reaction: MessageReactionType, userReactionIDs: Set<MessageReactionType>) -> Color? {
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor

        if let color = color {
            return Color(color)
        } else {
            return nil
        }
    }
}
