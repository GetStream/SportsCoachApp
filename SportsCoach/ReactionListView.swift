//
//  ReactionListView.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 27.9.24.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ReactionListView: View {
    
    @Injected(\.images) var images
    
    @StateObject var viewModel: ReactionListViewModel
    
    init(message: ChatMessage) {
        _viewModel = StateObject(wrappedValue: ReactionListViewModel(message: message))
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 24) {
                ForEach(viewModel.reactions) { reaction in
                    HStack(spacing: 2) {
                        if let image = images.availableReactions[reaction]?.largeIcon {
                            Button {
                                withAnimation {
                                    viewModel.selectedReaction = reaction
                                }
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                            }
                            Text("\(viewModel.count(for: reaction))")
                        }
                    }
                    .overlay(
                        reaction == viewModel.selectedReaction ? VStack {
                            Spacer()
                            Rectangle()
                                .fill(.customBlue)
                                .frame(width: 40, height: 4)
                                .offset(y: 16)
                        } : nil
                    )
                }
            }
            .padding(.all, 8)
            .padding(.top, 4)

            Divider()
            
            if viewModel.selectedReaction != nil {
                ScrollView {
                    VStack {
                        ForEach(viewModel.filteredReactions) { reaction in
                            HStack(spacing: 16) {
                                MessageAvatarView(avatarURL: reaction.author.imageURL)
                                Text(reaction.author.name ?? reaction.author.id)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
            
            Spacer()
        }
    }
}

class ReactionListViewModel: ObservableObject {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var reactions: [MessageReactionType]
    @Published var selectedReaction: MessageReactionType? {
        didSet {
            if let selectedReaction {
                loadReactions(for: selectedReaction)
            }
        }
    }
    @Published var filteredReactions = [ChatMessageReaction]()
    
    let message: ChatMessage
    
    private var reactionListController: ChatReactionListController?
    
    init(message: ChatMessage) {
        self.message = message
        let reactions = Self.reactions(from: message)
        self.reactions = reactions
        self.selectedReaction = reactions.first
        if let selectedReaction {
            loadReactions(for: selectedReaction)
        }
    }
    
    func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
    
    private static func reactions(from message: ChatMessage) -> [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: InjectedValues[\.utils].sortReactions)
    }
    
    private func loadReactions(for type: MessageReactionType) {
        reactionListController = chatClient.reactionListController(
            query: .init(
                messageId: message.id,
                filter: .equal(.reactionType, to: type)
            )
        )
        reactionListController?.synchronize { [weak self] _ in
            if let reactions = self?.reactionListController?.reactions {
                self?.filteredReactions = Array(reactions)
            }
        }
    }
}
