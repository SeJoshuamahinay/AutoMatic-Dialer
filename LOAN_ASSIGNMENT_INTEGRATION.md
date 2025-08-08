# Lenderly Dialer - Loan Assignment Integration

This document describes the implementation of the loan assignment API integration for the Lenderly Dialer Flutter app.

## 🎯 Overview

The integration allows users to request account assignments from the backend API and view them organized by bucket types (Frontend, Middlecore, Hardcore). The system prioritizes co-maker phone numbers for dialing purposes.

## 📁 Key Files Implemented

### 1. Models (`lib/commons/models/loan_models.dart`)
- **Borrower**: Contains borrower and co-maker information with phone numbers
- **LoanRecord**: Individual loan record with all loan details
- **AssignmentData**: Container for assigned loans organized by buckets
- **AssignmentResponse**: API response wrapper
- **BucketType**: Enum for bucket types (frontend, middlecore, hardcore)

### 2. Service (`lib/commons/services/accounts_bucket_service.dart`)
- **assignLoansToUser()**: Posts user_id to assign-loans endpoint
- **getUserAssignedLoans()**: Retrieves assigned loans for a user
- **getLoansByBucket()**: Filter loans by bucket type
- **getCoMakerPrioritizedLoansByBucket()**: Prioritizes co-maker phone numbers
- **getBucketStatistics()**: Provides analytics for each bucket

### 3. Views
- **BucketSelectionView** (`lib/views/bucket_selection_view.dart`): Main dashboard showing bucket overview
- **BucketView** (`lib/views/bucket_view.dart`): Detailed view for each bucket with calling functionality
- **SettingsView**: Updated to trigger loan assignment

## 🔧 API Integration

### Endpoint Used
- **POST** `http://localhost:8000/api/lenderly/dialer/assign-loans`
- **Request Body**: `{"user_id": "65"}`
- **Authentication**: Bearer token from user session

### Phone Number Prioritization
The system prioritizes co-maker phone numbers for dialing:

1. **Primary Contact**: Co-maker phone (if available)
2. **Fallback**: Borrower phone (if co-maker unavailable)
3. **Visual Indicators**: Green icons for co-maker, blue for borrower phones

## 🚀 User Flow

1. **Trigger**: User taps "Request Data" in Settings
2. **Assignment**: System posts user_id to assign-loans API
3. **Navigation**: Auto-navigates to bucket selection view
4. **Bucket Selection**: User selects Frontend/Middlecore/Hardcore
5. **Account Management**: View and dial assigned accounts

## 📱 Features

### Bucket Selection View
- Overview of total assigned accounts
- Statistics per bucket (total, dialable, co-maker coverage)
- Color-coded buckets (Green=Frontend, Orange=Middlecore, Red=Hardcore)

### Individual Bucket Views
- **Priority Sorting**: Co-maker phones listed first
- **Direct Dialing**: Tap phone icon to call
- **Statistics**: Real-time bucket analytics
- **Toggle**: Switch between co-maker priority and original order

### Phone Dialing
- Uses `flutter_phone_direct_caller` package
- Visual feedback for call attempts
- Error handling for failed calls

## 🎨 UI/UX Design

### Color Scheme
- **Frontend Bucket**: Green (#4CAF50)
- **Middlecore Bucket**: Orange (#FF9800)
- **Hardcore Bucket**: Red (#F44336)

### Visual Indicators
- **Co-maker Priority**: Bold text, priority icons
- **Loading States**: Progress indicators during API calls
- **Status Feedback**: Snackbars for success/error messages

## 🔒 Error Handling

- **Network Errors**: Graceful fallback with user notifications
- **Authentication**: Token validation and refresh
- **API Errors**: Detailed error messages from backend
- **Phone Calls**: Error handling for failed call attempts

## 📊 Statistics & Analytics

Each bucket provides:
- Total loan count
- Dialable accounts (with valid phone numbers)
- Co-maker phone availability percentage
- Borrower-only phone counts
- Accounts without phone numbers

## 🔄 Data Flow

```
Settings "Request Data" → 
  AccountsBucketService.assignLoansToUser() → 
    API Response → 
      BucketSelectionView → 
        BucketView → 
          Phone Dialing
```

## 🛠️ Configuration

### Environment Variables Required
- `API_BASE_URL`: Backend API URL (default: http://localhost:8000)
- Authentication token stored via SharedPrefsStorageService

### Dependencies Used
- `http`: API calls
- `flutter_phone_direct_caller`: Phone calling
- `shared_preferences`: Token storage
- `flutter_dotenv`: Environment configuration

## 🧪 Testing

### Manual Testing Steps
1. Ensure user is logged in with valid session
2. Tap "Request Data" in Settings
3. Verify API call to assign-loans endpoint
4. Check bucket selection view displays correctly
5. Navigate to individual bucket views
6. Test phone dialing functionality
7. Verify co-maker phone prioritization

### API Testing
- Test with different user IDs
- Verify token authentication
- Test network error scenarios
- Check response parsing

## 📈 Future Enhancements

1. **Call History**: Track dialing attempts and outcomes
2. **Offline Support**: Cache assigned accounts for offline access
3. **Search & Filter**: Enhanced filtering options within buckets
4. **Call Scripts**: Integration with predefined calling scripts
5. **Performance Metrics**: Track success rates by bucket type

## 🐛 Known Issues

- Print statements used for debugging (should be replaced with proper logging)
- Some deprecated methods in color usage (minor cosmetic warnings)
- Error handling could be more granular for specific HTTP status codes

## 📝 Notes

- Co-maker phone numbers are prioritized as per business requirements
- All phone calls use the device's native dialer
- Assignment data is not persisted locally (fetched fresh each time)
- The system handles up to 1M total assignment limit as per API documentation
