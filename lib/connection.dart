class Connection {
  final bool active;
  final String host;
  final String user;
  final String passwd;
  Connection(this.active, this.host, this.user, this.passwd);

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'host': host,
      'user': user,
      'passwd': passwd
    };
  }
}