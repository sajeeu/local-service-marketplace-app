import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/features/customers/data/customer_profile_api.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart'
    as customer;
import 'package:frontend/features/customers/presentation/create_customer_profile_screen.dart';
import 'package:frontend/features/providers/data/provider_profile_api.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';
import 'package:frontend/features/providers/presentation/create_provider_profile_screen.dart';

class _FakeProviderProfileApi implements ProviderProfileApi {
  @override
  Future<ProviderProfile> create(CreateProviderProfileInput input) async {
    throw const ApiAppException(
      message: 'Provider profile already exists',
      code: 'CONFLICT',
    );
  }

  @override
  Future<ProviderProfile> getMe() async {
    throw const ApiAppException(
      message: 'Provider profile not found',
      code: 'NOT_FOUND',
    );
  }

  @override
  Future<ProviderProfile> update(UpdateProviderProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<ProviderProfile> deactivate() {
    throw UnimplementedError();
  }

  @override
  Future<ProviderProfile> restore() {
    throw UnimplementedError();
  }
}

class _FakeCustomerProfileApi implements CustomerProfileApi {
  @override
  Future<customer.CustomerProfile> create(
    customer.CreateCustomerProfileInput input,
  ) async {
    return customer.CustomerProfile(
      id: 'cp_1',
      userId: 'u1',
      displayName: input.displayName,
      contactEmail: input.contactEmail,
      status: 'ACTIVE',
      completion: const customer.ProfileCompletion(
        status: 'COMPLETE',
        percent: 100,
      ),
    );
  }

  @override
  Future<customer.CustomerProfile> getMe() async {
    throw const ApiAppException(
      message: 'Customer profile not found',
      code: 'NOT_FOUND',
    );
  }

  @override
  Future<customer.CustomerProfile> update(
    customer.UpdateCustomerProfileInput input,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<customer.CustomerProfile> deactivate() {
    throw UnimplementedError();
  }

  @override
  Future<customer.CustomerProfile> restore() {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('provider create validates display name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerProfileApiProvider.overrideWithValue(
            _FakeProviderProfileApi(),
          ),
        ],
        child: const MaterialApp(home: CreateProviderProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create profile'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create profile'));
    await tester.pumpAndSettle();

    expect(find.text('Display name is required'), findsOneWidget);
  });

  testWidgets('provider create shows API error snackbar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerProfileApiProvider.overrideWithValue(
            _FakeProviderProfileApi(),
          ),
        ],
        child: const MaterialApp(home: CreateProviderProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Acme');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create profile'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create profile'));
    await tester.pumpAndSettle();

    expect(find.text('Provider profile already exists'), findsOneWidget);
  });

  testWidgets('customer create validates display name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerProfileApiProvider.overrideWithValue(
            _FakeCustomerProfileApi(),
          ),
        ],
        child: const MaterialApp(home: CreateCustomerProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create profile'));
    await tester.pumpAndSettle();

    expect(find.text('Display name is required'), findsOneWidget);
  });
}
