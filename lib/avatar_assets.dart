const List<String> avatarAssets = [
  'assets/images/avatar_0.png',
  'assets/images/avatar_1.png',
  'assets/images/avatar_2.png',
  'assets/images/avatar_3.png',
  'assets/images/avatar_4.png',
];

int normalizarAvatarId(dynamic valor) {
  final id = (valor as num?)?.toInt() ?? 0;

  if (id < 0 || id >= avatarAssets.length) {
    return 0;
  }

  return id;
}
