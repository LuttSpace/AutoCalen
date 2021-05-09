class User{
  String _name;
  String _email;
  String _photoURL;
  String _signInWith;
  bool _needAlarms;

  User(this._name, this._email, this._photoURL, this._signInWith,this._needAlarms); // 생성자
  User.fromJson(Map<String, dynamic> json) // 생성자 (Firestore 에서 가져온 데이터 이용)
      : _name = json['name'],
        _email = json['email'],
        _photoURL = json['photoURL'],
        _signInWith = json['signInWith'];

  String get name => _name;
  String get email => _email;
  String get photoURL => _photoURL;
  String get signInWith => _signInWith;
  bool get needAlarms => _needAlarms;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return {
      'name': _name,
      'email': _email,
      'photoURL': _photoURL,
      'signInWith': _signInWith,
      'needAlarms':_needAlarms
    };
  }
}