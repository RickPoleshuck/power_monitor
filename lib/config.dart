class Config {
  final bool active;
  final String host;
  final String user;
  final String passwd;
  final double delayMin;
  Config(this.active, this.host, this.user, this.passwd, this.delayMin);

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'host': host,
      'user': user,
      'passwd': passwd
    };
  }
}