final List<String> langHun = [
  'Vissza',
  'Lobby készítése',
  'Aktív lobbik',
  'Eredmények',
  'Bejelentkezés',
  'Kijelentezés',
  'Kijelentkezés Googleból',
  'Google bejelentkezés',
  'Játékszabályok',
  'Tovább',
  'Játékosok száma:',
  'Lobbi neve',
  'Becenév'
];

final List<String> langEng = [
  'Back',
  'Create lobby',
  'Active lobbies',
  'Results',
  'Sign in',
  'Sign out',
  'Sign out from Google',
  'Google sign in',
  'Rules',
  'Next',
  'Number of players:',
  'Lobby name',
  'Nickname'

];

List<String> language = langHun;
bool lang = false;

void setLanguage(bool langValue) {
  lang = langValue;
  changeLanguage();
}

List<String> changeLanguage() {
  if (lang) {
    return language = langEng;
  } else {
    return language = langHun;
  }
}