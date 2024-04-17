final Map<String, String> langMapEng = {
  'Back': 'Back',
  'CreateLobby': 'Create lobby',
  'ActiveLobbies': 'Active lobbies',
  'Results': 'Results',
  'SignIn': 'Sign in',
  'SignOut': 'Sign out',
  'GoogleSignOut': 'Sign out from Google',
  'GoogleSignIn': 'Google sign in',
  'Rules': 'Rules',
  'Next': 'Next',
  'NumberOfPlayers': 'Number of players:',
  'LobbyName': 'Lobby name',
  'Nickname': 'Nickname',
  'Players': 'Players',
  'Ready': 'Ready'
};

final Map<String, String> langMapHun = {
  'Back': 'Vissza',
  'CreateLobby': 'Lobbi készítése',
  'ActiveLobbies': 'Aktív lobbik',
  'Results': 'Eredmények',
  'SignIn': 'Bejelentkezés',
  'SignOut': 'Kijelentkezés',
  'GoogleSignOut': 'Kijeletkezés Googleból',
  'GoogleSignIn': 'Google bejelentkezés',
  'Rules': 'Szabályok',
  'Next': 'Tovább',
  'NumberOfPlayers': 'Játékosok száma:',
  'LobbyName': 'Lobbi neve',
  'Nickname': 'Becenév',
  'Players': 'Játékosok',
  'Ready': 'Mehet'
};
final Map<String, String> langMapTur = {
  'Back': 'törökVissza',
  'CreateLobby': 'törökLobbi készítése',
  'ActiveLobbies': 'törökAktív lobbik',
  'Results': 'törökEredmények',
  'SignIn': 'törökBejelentkezés',
  'SignOut': 'törökKijelentkezés',
  'GoogleSignOut': 'törökKijeletkezés Googleból',
  'GoogleSignIn': 'törökGoogle bejelentkezés',
  'Rules': 'törökSzabályok',
  'Next': 'törökTovább',
  'NumberOfPlayers': 'törökJátékosok száma:',
  'LobbyName': 'törökLobbi neve',
  'Nickname': 'törökBecenév',
  'Players': 'törökJátékosok',
  'Ready': 'törökMehet'
};

Map<String, String> languageMap = langMapHun;
String lang = 'Hun';

void setLanguage(String langValue) {
  lang = langValue;
  changeLanguageMap();
}

Map<String, String> changeLanguageMap() {
  if (lang == 'Eng') {
    return languageMap = langMapEng;
  } else if (lang == 'Tur') {
    return languageMap = langMapTur;
  }else {
    return languageMap = langMapHun;
  }
}
