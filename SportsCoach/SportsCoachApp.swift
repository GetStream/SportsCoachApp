//
//  SportsCoachApp.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 25.9.24.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

@main
struct SportsCoachApp: App {
    
    @State var streamChat: StreamChat?
    @State var tabSelection: Int = 2
    
    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = applicationGroupIdentifier

        let client = ChatClient(config: config)
        return client
    }()
    
    init() {
        var colors = ColorPalette()
        colors.messageCurrentUserBackground = [UIColor(Color.customBlue)]
        colors.messageOtherUserBackground = [colors.background6]
        colors.messageCurrentUserTextColor = .white
        
        let images = Images()
        images.openAttachments = UIImage(systemName: "plus.app.fill")!
        images.shrinkInputArrow = UIImage(systemName: "plus.app.fill")!
        
        images.availableReactions = [
            .init(rawValue: "love"): ChatMessageReactionAppearance(
                smallIcon: UIImage(named: "heart-eyes")!,
                largeIcon: UIImage(named: "heart-eyes")!
            ),
            .init(rawValue: "haha"): ChatMessageReactionAppearance(
                smallIcon: UIImage(named: "laughing")!,
                largeIcon: UIImage(named: "laughing")!
            ),
            .init(rawValue: "like"): ChatMessageReactionAppearance(
                smallIcon: UIImage(named: "thumbs-up")!,
                largeIcon: UIImage(named: "thumbs-up")!
            ),
            .init(rawValue: "sad"): ChatMessageReactionAppearance(
                smallIcon: UIImage(named: "crying")!,
                largeIcon: UIImage(named: "crying")!
            ),
            .init(rawValue: "wow"): ChatMessageReactionAppearance(
                smallIcon: UIImage(named: "sweat-smile")!,
                largeIcon: UIImage(named: "sweat-smile")!
            )
        ]
        
        let appearance = Appearance(colors: colors, images: images)
        
        let messageDisplayOptions = MessageDisplayOptions(lastInGroupHeaderSize: 24, reactionsPlacement: .bottom)
        let config = MessageListConfig(
            messageDisplayOptions: messageDisplayOptions,
            dateIndicatorPlacement: .messageList,
            handleTabBarVisibility: false
        )
        let utils = Utils(messageListConfig: config)
        
        _streamChat = State(initialValue: StreamChat(chatClient: chatClient, appearance: appearance, utils: utils))
        chatClient.connectUser(
            userInfo: UserInfo(
                id: "anakin_skywalker",
                imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/6/6f/Anakin_Skywalker_RotS.png")
            ),
            token: try! Token(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYW5ha2luX3NreXdhbGtlciJ9.ZwCV1qPrSAsie7-0n61JQrSEDbp6fcMgVh4V2CB0kM8")
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection,
                    content:  {
                Text("Home").tabItem { Label("Home", systemImage: "house") }.tag(0)
                Text("Roster").tabItem { Label("Roster", systemImage: "person.2") }.tag(1)
                ChatChannelListView(viewFactory: SportsCoachViewFactory.shared, handleTabBarVisibility: false)
                    .tabItem { Label("Chat", systemImage: "message.circle") }.tag(2)
                Text("Schedule").tabItem { Label("Schedule", systemImage: "calendar") }.tag(3)
                Text("Media").tabItem { Label("Media", systemImage: "person.crop.square.badge.camera") }.tag(4)
            })
            .tint(.customPurple)
        }
    }
}

public let apiKeyString = "zcgvnykxsfm8"
public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
