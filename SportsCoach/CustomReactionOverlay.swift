//
//  CustomReactionOverlay.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 27.9.24.
//
import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct CustomReactionsContainer: View {
    
    @State var showDetent: Bool = false
    
    let messageDisplayInfo: MessageDisplayInfo
    var snapshot: UIImage
    var onBackgroundTap: () -> Void
    
    var body: some View {
        Color.clear.onAppear {
            showDetent = true
        }
        .sheet(isPresented: $showDetent, onDismiss: {
            onBackgroundTap()
        }, content: {
            CustomReactionOverlay(
                messageDisplayInfo: messageDisplayInfo,
                snapshot: snapshot,
                onBackgroundTap: onBackgroundTap
            )
            .presentationDetents([.height(height)])
        })
    }
    
    var height: CGFloat {
        if messageDisplayInfo.showsBottomContainer && !messageDisplayInfo.showsMessageActions {
            return 230
        } else {
            return 300
        }
    }
}

struct CustomReactionOverlay: View {
    
    @Injected(\.images) var images
    @Injected(\.utils) var utils
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    var snapshot: UIImage
    var onBackgroundTap: () -> Void
    var showListOfReactions: Bool
    
    @State var offset: CGFloat = 200
    
    init(viewModel: ReactionsOverlayViewModel? = nil, messageDisplayInfo: MessageDisplayInfo, snapshot: UIImage, onBackgroundTap: @escaping () -> Void) {
        self.snapshot = snapshot
        self.onBackgroundTap = onBackgroundTap
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeReactionsOverlayViewModel(
                message: messageDisplayInfo.message
            )
        )
        showListOfReactions = messageDisplayInfo.showsBottomContainer && !messageDisplayInfo.showsMessageActions
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack(alignment: .leading) {
                Spacer()
                
                if showListOfReactions {
                    ReactionListView(message: viewModel.message)
                        .padding(.leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .offset(y: offset)
                        .onAppear {
                            withAnimation {
                                offset = 0
                            }
                        }
                } else {
                    VStack {
                        HStack(alignment: .top, spacing: 32) {
                            ForEach(reactions) { reaction in
                                if let image = iconProvider(for: reaction) {
                                    Button {
                                        withAnimation {
                                            viewModel.reactionTapped(reaction)
                                            NotificationCenter.default.post(
                                                name: Notification.Name(rawValue: "reactionsUpdated"),
                                                object: nil,
                                                userInfo: ["messageId": viewModel.message.id]
                                            )
                                            dismissView()
                                        }
                                    } label: {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 36)
                                    }
                                }
                            }
                                                                            
                            Spacer()
                        }
                        .padding(.top)
                        
                        ScrollView {
                            VStack {
                                Button {
                                    copyMessage()
                                } label: {
                                    HStack {
                                        Text("Copy")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "rectangle.on.rectangle")
                                            .foregroundColor(.customBlue)
                                    }
                                }
                                .padding(.vertical)
                                
                                if viewModel.message.isSentByCurrentUser {
                                    Button {
                                        editMessage()
                                    } label: {
                                        HStack {
                                            Text("Edit")
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: "pencil.line")
                                                .foregroundColor(.customBlue)
                                        }
                                    }
                                    .padding(.vertical)
                                    
                                    Button {
                                        deleteMessage()
                                    } label: {
                                        HStack {
                                            Text("Delete")
                                                .foregroundColor(.black)
                                            Spacer()
                                            Image(systemName: "trash")
                                                .foregroundColor(.customBlue)
                                        }
                                    }
                                    .padding(.vertical)
                                }
                                
                                Button {
                                    replyToMessage()
                                } label: {
                                    HStack {
                                        Text("Reply")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "arrowshape.turn.up.left")
                                            .foregroundColor(.customBlue)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(16)
                    .offset(y: offset)
                    .onAppear {
                        withAnimation {
                            offset = 0
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func copyMessage() {
        
    }
    
    func editMessage() {
        
    }
    
    func deleteMessage() {
        
    }
    
    func replyToMessage() {
        
    }
    
    private var reactions: [MessageReactionType] {
        images.availableReactions.keys
            .map { $0 }
            .sorted(by: utils.sortReactions)
    }
    
    private func iconProvider(for reaction: MessageReactionType) -> UIImage? {
        images.availableReactions[reaction]?.largeIcon
    }
    
    private func dismissView() {
        onBackgroundTap()
    }
}

struct CustomMessageDateView: View {
    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    var message: ChatMessage
    
    var text: String {
        dateFormatter.string(from: message.createdAt)
    }
    
    var body: some View {
        Text(text)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .font(fonts.footnote)
            .foregroundColor(Color(colors.textLowEmphasis))
            .animation(nil)
    }
}
