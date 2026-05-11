import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/src/presentation/pages/auth/signup_page.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';
import 'package:login_app/src/presentation/bloc/auth_state.dart';
import 'package:mockito/mockito.dart';

import 'login_page_test.mocks.dart';

void main() {
  group('SignupPage Basic UI Tests', () {
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
          child: const SignupPage(),
        ),
      );
    }

    testWidgets('should display signup page elements',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('signup_appbar')), findsOneWidget);
      expect(find.byKey(const Key('signup_icon')), findsOneWidget);
    });

    testWidgets('should find all input fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('signup_name_field')), findsOneWidget);
      expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
      expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
      expect(find.byKey(const Key('signup_confirm_password_field')),
          findsOneWidget);
    });

    testWidgets('should find visibility toggle buttons',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('signup_password_visibility_toggle')),
          findsOneWidget);
      expect(find.byKey(const Key('signup_confirm_password_visibility_toggle')),
          findsOneWidget);
    });

    testWidgets('should find buttons', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('signup_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('signup_login_button')), findsOneWidget);
    });
  });
}
