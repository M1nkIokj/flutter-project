import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/src/presentation/pages/auth/login_page.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';
import 'package:login_app/src/presentation/bloc/auth_state.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'login_page_working_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  group('LoginPage Working Tests', () {
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
      );
    }

    testWidgets('should display login page elements',
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
    });

    testWidgets('should find email and password fields',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
      when(mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_visibility_toggle')),
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
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('login_signup_button')), findsOneWidget);
    });
  });
}
