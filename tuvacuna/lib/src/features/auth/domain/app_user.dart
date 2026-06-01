enum AppRole { paciente, organizador, especialista }

class AppUser {
  final String rut;
  final String name;
  final AppRole role;

  const AppUser({
    required this.rut,
    required this.name,
    required this.role,
  });
}
