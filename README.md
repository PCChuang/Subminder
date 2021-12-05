
<div id="top"></div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://i.imgur.com/9epcFk5.png" alt="Logo" width="200" height="200">
  </a>

  <h3 align="center">Subminder</h3>
  
  <p align="center">
  <a href="https://apple.co/3FWRtpX">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a>

<p align="center">
<img src="https://img.shields.io/github/v/release/PCChuang/Subminder?style=for-the-badge"/>
<img src="https://img.shields.io/github/license/PCChuang/Subminder?style=for-the-badge"/>
</p>
</div>

<!-- PROJECT  SUMMARY -->

> A management application for personal subscriptions. With Subminder, users can easily track subscriptions with customization options, and connect with friends to manage shared subscriptions and payments.

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#features">Features</a>
      <ul>
        <li><a href="#sign-in-with-apple">Sign In with Apple</a></li>
        <li><a href="#sign-in-with-apple">Personal Subscription</a></li>
        <ul>
        <li><a href="#add-personal-subscriptions-with-customization">Add Personal Subscriptions with Customization</a></li>
        <li><a href="#reminder">Reminder</a></li>
        <li><a href="#sort">Sort</a></li>
        <li><a href="#editdelete-subscription">Edit/Delete Subscription</a></li>
        </ul>
        <li><a href="#friend">Friend</a></li>
        <ul>
        <li><a href="#search-user-and-send-friend-request">Search User and Send Friend Request</a></li>
        <li><a href="#confirm-friend-request">Confirm Friend Request</a></li>
        </ul>
        <li><a href="#group">Group</a></li>
         <ul>
        <li><a href="#create-group">Create Group</a></li>
        <li><a href="#create-group-subscription">Create Group Subscription</a></li>
        <li><a href="#send-payment-information">Send Payment Information</a></li>
        <li><a href="#confirm-payment">Confirm Payment</a></li>
        <li><a href="#renew-payment-status">Renew Payment Status</a></li>
        </ul>
         <li><a href="#settings">Settings</a></li>
         <ul>
        <li><a href="#profile-settings">Profile Settings</a></li>
        </ul>
      </ul>
    </li>
    <li>
      <a href="#highlights">Highlights</a>
    </li>
    <li><a href="#third-party-libraries">Third-Party Libraries</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Features

### Sign In with Apple

Implemented `Sign In with Apple` with `Firebase Authentication` to build a secure authentication system.

<p>
<img src="https://i.imgur.com/80t2ps7.png" width="185" height="400"/>
</p>

<p align="right">(<a href="#top">back to top</a>)</p>

### Personal Subscription

#### # Add Personal Subscriptions with Customization

Provided users with options to add customized personal subscriptions.

<p>
<img src="https://i.imgur.com/VBgriXG.png" width="185" height="400"/>
<img src="https://i.imgur.com/X95jaHP.png" width="185" height="400"/>
</p>

#### # Reminder

Sent reminder notification according to user's setting by implemented `User Notifications`.

<p>
<img src="https://i.imgur.com/L2fNTTi.jpg" width="185" height="400"/>
</p>

#### # Sort

User can sort subscriptions by subscription price or billing due date.

<p>
<img src="https://i.imgur.com/nKaNVm3.gif" width="185" height="400"/>
</p>

#### # Edit/Delete Subscription

With a tap on subscriptions, user will be able to edit/delete selected subscription.

<p>
<img src="https://i.imgur.com/etCPi23.gif" width="185" height="400"/>
</p>

<p align="right">(<a href="#top">back to top</a>)</p>

### Friend

#### # Search User and Send Friend Request

User can search another user with ID and send friend request. (User ID can be found in `setting` tab)

<p>
<img src="https://i.imgur.com/AWqWtMI.gif" width="185" height="400"/>
</p>

#### # Confirm Friend Request

User can accept/decline friend requests. After acceptance, new friends will appear in user's friend list.

<p>
<img src="https://i.imgur.com/XQ0OUSr.gif" width="185" height="400"/>
</p>

<p align="right">(<a href="#top">back to top</a>)</p>

### Group

User can create group for shared subscriptions with friends to track subscriptions and payment status.

<p>
<img src="https://i.imgur.com/nGWqyxe.png" width="185" height="400"/>
</p>

#### # Create Group

To create a new group, user needs to invite friends and give a name to the group. Invited friends will be added to the group automatically when the group is created.

<p>
<img src="https://i.imgur.com/0wV3vHT.gif" width="185" height="400"/>
</p>

#### # Create Group Subscription

After group is created, the host of the group can create group subscription by tapping the group cell. The subscription price will be split equally based on the number of group members. Once the host creates the subscription, all members will receive a new group subscription card accordingly in their summary tab.

<p>
<img src="https://i.imgur.com/YyGHu0R.gif" width="185" height="400"/>
</p>

#### # Send Payment Information

Members in group can send payment information to the host for payment check.

<p>
<img src="https://i.imgur.com/tRfObG0.gif" width="185" height="400"/>
</p>

#### # Confirm Payment

Host in group can check the payment information sent from members. After acceptance, the payment status of host and members will be updated.

<p>
<img src="https://i.imgur.com/iEy0fPp.gif" width="185" height="400"/>
</p>

#### # Renew Payment Status

Renewed payment status accordingly with `Date` implementation. By checking user's log-in date,  if it is later than due date of subscription, payment status of the user will be updated automatically.

<p align="right">(<a href="#top">back to top</a>)</p>

### Settings

#### # Profile Settings

- Applied `UIImagePickerController` to create image picker to allow users to upload profile image from camera/photo library.
- Implemented `UIPasteboard` and users can easily copy their own ID.

<p>
<img src="https://i.imgur.com/S4o6sCy.png" width="185" height="400"/>
</p>

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- Highlights -->
## Highlights

- Built the app with `MVC` architecture to attain better reusability and maintainability of codes
- Designed data structure and managed Back-End data with `Firebase Firestore`
- Resolved `complex user flow` of shared subscriptions, and achieved to renew payment status accordingly
- Implemented `User Notifications` to send reminders at a specific time customized by user
- Handled massive calculation and conversion of `Date` data with `DateComponents` and `DateFormatter`
- Connected `RESTful API` with `URLSession` for real-time exchange rates and currency conversion
- Applied `UIColorPickerViewController` to create color picker to achieve better customization
- Managed images with `Firebase Storage` and utilized storage space with image compression
- Created custom `UICollectionViewCell` and `UITableViewCell` in `Nibs` to achieve reusability of UI components
- Constructed UI with `Auto Layout` to ensure UI consistency applying to all devices

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- Third-Party Libraries -->
## Third-Party Libraries

- [SwiftLint](https://github.com/realm/SwiftLint) - enforces Swift style and conventions
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager) - handles Keyboard in iOS
- [CurrencyTextField](https://github.com/richa008/CurrencyTextField) - fixes the style of `UITextField` for price amount input
- [BEMCheckBox](https://github.com/Boris-Em/BEMCheckBox) - animated checkbox to improve UX
- [lottie-ios](https://lottiefiles.com) - adds animation in loading page
- [Firebase](https://firebase.google.com/docs/ios/setup)
  - Auth - authenticates users with `Sign In with Apple`
  - Firestore - stores and handles users data
  - Storage - stores profile images of users
  - Crashlytics - tracks crash and stability issues

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- Requirements -->
## Requirements

- Xcode 13.1+
- iOS 14.0+

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Dean Chuang - juangpochieh@gmail.com

<p align="right">(<a href="#top">back to top</a>)</p>
