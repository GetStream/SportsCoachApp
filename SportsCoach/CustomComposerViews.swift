//
//  CustomComposerViews.swift
//  SportsCoach
//
//  Created by Martin Mitrevski on 27.9.24.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

public struct CustomLeadingAttachmentView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?

    public init(
        pickerTypeState: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) {
        _pickerTypeState = pickerTypeState
        self.channelConfig = channelConfig
    }

    private var commandsAvailable: Bool {
        channelConfig?.commands.count ?? 0 > 0
    }

    public var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                if channelConfig?.uploadsEnabled == true {
                    Button {
                        withAnimation {
                            onTap(attachmentType: .media, selected: attachmentPickerType)
                        }
                    } label: {
                        image
                    }
                }
            case .collapsed:
                Button {
                    withAnimation {
                        pickerTypeState = .expanded(.none)
                    }
                } label: {
                    image
                }
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 8)
    }
    
    var image: some View {
        Image(systemName: "plus.square")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(height: 22)
            .foregroundColor(.customBlue)
    }
    
    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }
}

struct CustomTrailingComposerView: View {
    
    @EnvironmentObject var viewModel: MessageComposerViewModel
    var onTap: () -> Void
    
    var body: some View {
        if !viewModel.text.isEmpty {
            Button {
                onTap()
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 22)
                    .rotationEffect(Angle(degrees: 45))
                    .foregroundColor(Color.customBlue)
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 8)
        }
    }
}
