import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/src/presentation/pages/main/main_page.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';
import 'package:login_app/src/presentation/bloc/auth_state.dart';
import 'package:login_app/src/domain/entities/user.dart';
import 'package:mockito/mockito.dart';

import 'login_page_test.mocks.dart';

void main() {
  group('MainPage Basic UI Tests', () {
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
          child: const MainPage(),
        ),
      );
    }

    testWidgets('should display main page elements',
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
      expect(find.byKey(const Key('main_appbar')), findsOneWidget);
      expect(find.text('Pokemon Game'), findsOneWidget);
      expect(find.byKey(const Key('main_logout_button')), findsOneWidget);
    });

    testWidgets('should find pokemon icon and user info elements',
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
      expect(find.byKey(const Key('main_pokemon_icon')), findsOneWidget);
      expect(find.byKey(const Key('main_user_name_text')), findsOneWidget);
      expect(find.byKey(const Key('main_user_email_text')), findsOneWidget);
    });

    testWidgets('should find play game button', (WidgetTester tester) async {
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
      expect(find.byKey(const Key('main_play_game_button')), findsOneWidget);
      expect(find.text('Play Game'), findsOneWidget);
    });
  });
}
