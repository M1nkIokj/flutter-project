# Supabase Setup Guide

This Flutter login app now supports Supabase as a real database backend. Follow these steps to configure it:

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up for a free account
3. Create a new project
4. Wait for the project to be ready (usually takes 1-2 minutes)

## 2. Get Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Project Settings** > **API**
3. Copy the **Project URL** and **anon public key**

## 3. Configure the App

1. Open `lib/src/core/constants/supabase_constants.dart`
2. Replace the placeholder values:

```dart
class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon public key
}
```

## 4. Enable Authentication

1. In your Supabase dashboard, go to **Authentication** > **Settings**
2. Enable **Email** authentication provider
3. Configure email settings as needed

## 5. Test the App

Now you can run the app and test real authentication:

- **Sign Up**: Create new accounts with real email and password
- **Login**: Use your registered credentials
- **Persistence**: Users stay logged in across app restarts
- **Sign Out**: Properly logs out and clears session

## Features

✅ **Real Authentication**: No more mock data  
✅ **Persistent Sessions**: Users stay logged in  
✅ **Secure**: Uses Supabase's secure authentication  
✅ **Clean Architecture**: Maintains clean code structure  
✅ **Error Handling**: Proper error messages from Supabase  

## Database Schema

The app uses Supabase's built-in `auth.users` table. No additional database setup required!

## Troubleshooting

- **Invalid URL/Key**: Double-check your Supabase credentials
- **Network Issues**: Ensure you have internet connection
- **Email Confirmation**: Check if email confirmation is enabled in Supabase settings
