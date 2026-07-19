import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session placeholder for Phase 1 Identity.
/// Ownership: Session state (auth identity/permissions) — empty until Phase 1.
class SessionState {
  const SessionState({this.isAuthenticated = false});

  final bool isAuthenticated;
}

final sessionProvider = Provider<SessionState>((ref) {
  return const SessionState();
});
