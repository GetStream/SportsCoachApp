## Sports Coach Sample app

This is a sample app that shows the extensibility of the Stream Chat SDK, with a custom implementation of several parts of the chat experience:
- custom bubble that contains bottom style reactions
- custom reactions picker
- custom message actions
- different positioning of read indicators 
- styling of the composer
- theming, colors and icons adjustments

### Would you like to add these capabilities and more to your App?

This project uses [Stream](https://getstream.io/)'s battle-tested chat infrastructure. Check out our:

- ⭐ [Chat API](https://getstream.io/chat/)
- 📱 [Video API](https://getstream.io/video/)
- 🔔 [Activity Feeds](https://getstream.io/activity-feeds/)

### Running the sample

In order to run the sample, you first need to clone it:

```
git clone https://github.com/GetStream/SportsCoachApp.git your_local_location
```

Next, open Xcode, and wait for a few seconds until all the packages are downloaded.

When that process finishes, you just press the play button, which will run the app from your simulator or device.

### Running with your API key

The app is configured to run with Stream's demo app API key. In order to run it with your own key, change line 96 in `SportsCoachApp.swift`:

```swift
public let apiKeyString = "your api key"
```

Additionally, you need to update the user that is connecting to the Stream backend, with your own user and token (line 71-76) in the same file:

```swift
chatClient.connectUser(
    userInfo: UserInfo(
        id: "your user id",
        imageURL: URL(string: "your user image url")
    ),
    token: try! Token(rawValue: "your token")
)
```

For more info about our SwiftUI SDK, please check our [docs](https://getstream.io/chat/docs/sdk/ios/swiftui/getting-started/).
