import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/paciente_home_screen.dart';
import '../features/home/presentation/organizador_home_screen.dart';
import '../features/home/presentation/especialista_home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (authState?.role == AppRole.organizador) {
            return const OrganizadorHomeScreen();
          } else if (authState?.role == AppRole.especialista) {
            return const EspecialistaHomeScreen();
          } else {
            return const PacienteHomeScreen();
          }
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
