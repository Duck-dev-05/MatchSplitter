# MatchSplitter - iOS Invoicing App (iPhone 6s Plus Compatible)

A simplified iOS invoicing application built with Swift and SwiftUI, featuring local data storage using Core Data for iOS 15.0+ compatibility.

## Features

### Core Functionality (iOS 15.0+ Compatible)
- **Dashboard**: Overview of revenue, outstanding invoices, and recent activity
- **Invoice Management**: Create, edit, send, and track invoices
- **Client Management**: Manage client information and contact details
- **Payment Tracking**: Track multiple payment methods and partial payments
- **Status Management**: Track invoice status (Draft, Sent, Paid, Overdue, etc.)
- **Local Data Storage**: All data stored locally using Core Data

### iPhone 6s Plus Compatible
- **Minimum iOS Version**: iOS 15.0
- **Data Storage**: Core Data (instead of SwiftData which requires iOS 17.0+)
- **Optimized for older devices**: Simplified UI for better performance

## Project Structure

```
MatchSplitter/
├── MatchSplitter/
│   ├── MatchSplitterApp.swift      # App entry point with Core Data setup
│   ├── ContentView.swift           # Main tab navigation
│   ├── Assets.xcassets/            # App icons and assets
│   ├── Models/                      # Core Data models
│   │   ├── CoreDataModels.swift    # Core Data entity definitions
│   │   └── Models.xcdatamodeld/    # Core Data model file
│   └── Views/                       # UI views
│       ├── DashboardView.swift
│       ├── InvoicesView.swift
│       ├── AddInvoiceView.swift
│       ├── InvoiceDetailView.swift
│       ├── ClientsView.swift
│       ├── AddClientView.swift
│       └── ClientDetailView.swift
├── MatchSplitter.xcodeproj/        # Xcode project
├── Info.plist                      # App configuration
└── README.md                       # This file
```

## Requirements

- iOS 15.0+ (Compatible with iPhone 6s Plus)
- Xcode 14.0+
- Swift 5.0+

## Building the Project

### For Development on Mac:
1. Open `MatchSplitter.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### For Sideloadly on Windows (iPhone 6s Plus):
1. Transfer project to a Mac for building
2. Open in Xcode and build for "Any iOS Device"
3. Archive the project (Product → Archive)
4. Export the .app file
5. Use iOS App Signer to create .ipa file
6. Sideload using Sideloadly on Windows

## Data Models

### Client
- Contact information (name, email, phone)
- Address details
- Tax ID/VAT number
- Notes

### Invoice
- Invoice number and dates
- Client relationship (via ID reference)
- Tax and discount calculations
- Payment tracking
- Status management

### InvoiceItem
- Line items for invoices
- Quantity and pricing
- Tax and discount per item

### Payment
- Payment amount and method
- Reference numbers
- Payment date tracking

## Testing on iPhone 6s Plus

Your iPhone 6s Plus supports up to iOS 15.7.9, making it perfect for testing this app:

1. Build the app on a Mac
2. Create .ipa file using iOS App Signer
3. Use Sideloadly on Windows to install
4. Test full invoicing functionality

## Future Enhancements (iOS 17.0+ Only)
- Estimates and recurring billing
- Advanced reporting and analytics
- SwiftData migration for newer devices
- Export to PDF
- Email integration
- Payment gateway integration

## License

This project is created for business invoicing purposes.

## Support

For issues or questions, please refer to the project documentation or contact development support.