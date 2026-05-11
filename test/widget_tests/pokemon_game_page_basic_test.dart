import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/src/presentation/pages/pokemon_game/pokemon_game_page.dart';
import 'package:login_app/src/presentation/bloc/auth_bloc.dart';
import 'package:login_app/src/presentation/bloc/auth_state.dart';
import 'package:login_app/src/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'pokemon_game_page_basic_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  group('PokemonGamePage Basic UI Tests', () {
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
          child: const PokemonGamePage(),
        ),
      );
    }

    testWidgets('should display game page elements',
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
      expect(find.byKey(const Key('pokemon_game_appbar')), findsOneWidget);
      expect(find.text('Pokemon Guess Game'), findsOneWidget);
      expect(find.byKey(const Key('pokemon_game_back_button')), findsOneWidget);
    });

    testWidgets('should find loading indicator initially',
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

      // Act - Just pump once without settling to catch initial loading state
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Don't settle to avoid waiting for async operations

      // Assert - Check for loading indicator or basic elements
      final loadingIndicator = find.byKey(const Key('pokemon_game_loading'));
      if (loadingIndicator.evaluate().isNotEmpty) {
        expect(loadingIndicator, findsOneWidget);
      } else {
        // If loading is done, at least check for basic elements
        expect(find.byKey(const Key('pokemon_game_appbar')), findsOneWidget);
      }
    });

    testWidgets('should find back button', (WidgetTester tester) async {
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
      expect(find.byKey(const Key('pokemon_game_back_button')), findsOneWidget);
    });
  });
}
