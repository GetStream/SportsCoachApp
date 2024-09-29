//
//  SportsCoachViewFactory.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 25.9.24.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

class SportsCoachViewFactory: ViewFactory {

    @Injected(\.colors) var colors
    @Injected(\.chatClient) var chatClient
    
    private init() {}
    
    static let shared = SportsCoachViewFactory()
    
    var onTapMapping = [String: (() -> Void)?]()
    var onLongPressMapping = [String: (() -> Void)?]()
    
    func makeChannelHeaderViewModifier(for channel: ChatChannel) -> some ChatChannelHeaderViewModifier {
        CustomChannelHeaderModifier(channel: channel)
    }
    
    func makeBottomReactionsView(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        onTapMapping[message.id] = onTap
        onLongPressMapping[message.id] = onLongPress
        return EmptyView()
    }
    
    func makeMessageDateView(for message: ChatMessage) -> some View {
        EmptyView()
    }
    
    func makeMessageReadIndicatorView(channel: ChatChannel, message: ChatMessage) -> some View {
        EmptyView()
    }
    
    func makeMessageAuthorAndDateView(for message: ChatMessage) -> some View {
        EmptyView()
    }
    
    func makeChannelListTopView(searchText: Binding<String>) -> some View {
        EmptyView()
    }
    
    func makeReactionsOverlayView(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) -> some View {
        CustomReactionsContainer(
            messageDisplayInfo: messageDisplayInfo,
            snapshot: currentSnapshot,
            onBackgroundTap: onBackgroundTap
        )
    }
    
    func makeLeadingComposerView(state: Binding<PickerTypeState>, channelConfig: ChannelConfig?) -> some View {
        CustomLeadingAttachmentView(pickerTypeState: state, channelConfig: channelConfig)
    }
    
    func makeTrailingComposerView(enabled: Bool, cooldownDuration: Int, onTap: @escaping () -> Void) -> some View {
        CustomTrailingComposerView(onTap: onTap)
    }
    
    func makeLastInGroupHeaderView(for message: ChatMessage) -> some View {
        ZStack {
            if message.isSentByCurrentUser {
                EmptyView()
            } else {
                HStack {
                    Text(message.author.name ?? message.author.id)
                        .bold()
                        .font(.caption)
                        .foregroundColor(Color(colors.textLowEmphasis))
                        .padding(.leading, 60)
                    Spacer()
                }
            }
        }
    }
    
    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> some ViewModifier {
        CustomMessageBubbleModifier(
            message: messageModifierInfo.message,
            isFirst: messageModifierInfo.isFirst,
            injectedBackgroundColor: messageModifierInfo.injectedBackgroundColor,
            cornerRadius: messageModifierInfo.cornerRadius,
            forceLeftToRight: messageModifierInfo.forceLeftToRight,
            onTap: onTapMapping[messageModifierInfo.message.id] ?? {},
            onLongPress: onLongPressMapping[messageModifierInfo.message.id] ?? {}
        )
    }
}

struct CustomChannelHeaderModifier: ChatChannelHeaderViewModifier {
    
    @Injected(\.utils) var utils
    @Injected(\.chatClient) var chatClient
    
    @Environment(\.dismiss) var dismiss
    
    let channel: ChatChannel
    
    var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(channelNamer(channel, chatClient.currentUserId) ?? "")
                        .bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        Text("Custom implementation goes here")
                    } label: {
                        Image(systemName: "info.circle")
                            .fontWeight(.semibold)
                            .foregroundColor(.customBlue)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                            .foregroundColor(.gray)
                    }

                }
            }
            .navigationBarBackButtonHidden(true)
    }
}
