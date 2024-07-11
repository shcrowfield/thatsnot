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
  'EnterNickname': 'Enter a nickname',
  'Players': 'Players',
  'Ready': 'Ready',
  'Allow to Enter': 'Allow to Enter',
  'LobbyIsFull': 'Lobby is Full'
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
  'EnterNickname': 'Adj meg egy Becenévet',
  'Players': 'Játékosok',
  'Ready': 'Mehet',
  'Allow to Enter': 'Beléphet',
  'LobbyIsFull': 'A lobbi megtelt'
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
  'EnterNickname': 'Adj meg egy törökBecenevet',
  'Players': 'törökJátékosok',
  'Ready': 'törökMehet',
  'Allow to Enter': 'törökBeléphet',
  'LobbyIsFull': 'törökTele'
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
