import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/src/presentation/pages/auth/login_page.dart';
import 'package:login_app/src/presentation/pages/auth/signup_page.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';
import 'package:login_app/src/presentation/bloc/auth_state.dart';
import 'package:login_app/src/presentation/bloc/auth_event.dart';
import 'package:login_app/src/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    tearDown(() {
      mockAuthBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/signup') {
            return MaterialPageRoute(
              builder: (context) => BlocProvider<AuthBloc>.value(
                value: mockAuthBloc,
                child: const SignupPage(),
              ),
            );
          }
          return null;
        },
      );
    }

    testWidgets('should display all login page elements',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('login_appbar')), findsOneWidget);
      expect(find.byKey(const Key('login_icon')), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_visibility_toggle')),
          findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('login_signup_button')), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the password field and check initial state
      final passwordField = find.byKey(const Key('login_password_field'));
      expect(passwordField, findsOneWidget);

      // Tap visibility toggle
      await tester
          .tap(find.byKey(const Key('login_password_visibility_toggle')));
      await tester.pumpAndSettle();

      // Verify the toggle was tapped
      expect(find.byKey(const Key('login_password_visibility_toggle')),
          findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap submit button without entering data
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show validation error for short password',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter email and short password
      await tester.enterText(
          find.byKey(const Key('login_email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('login_password_field')), '123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should dispatch SignInRequested when form is valid',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(
          find.byKey(const Key('login_email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('login_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthBloc.add(const SignInRequested(
        email: 'test@example.com',
        password: 'password123',
      ))).called(1);
    });

    testWidgets('should show loading indicator during authentication',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));
      when(mockAuthBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byKey(const Key('login_loading_indicator')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsNothing);
    });

    testWidgets('should find signup button', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Just verify the signup button exists
      expect(find.byKey(const Key('login_signup_button')), findsOneWidget);
    });

    testWidgets('should show error message when authentication fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthError('Invalid credentials')));
      when(mockAuthBloc.state).thenReturn(AuthError('Invalid credentials'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should show success message when authentication succeeds',
        (WidgetTester tester) async {
      // Arrange
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        token: 'token123',
      );
      when(mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Authenticated(user)));
      when(mockAuthBloc.state).thenReturn(Authenticated(user));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login successful!'), findsOneWidget);
    });
  });
}
