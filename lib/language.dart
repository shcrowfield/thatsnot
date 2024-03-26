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

Map<String, String> languageMap = langMapHun;
bool lang = false;

void setLanguage(bool langValue) {
  lang = langValue;
  changeLanguageMap();
}

Map<String, String> changeLanguageMap() {
  if (lang) {
    return languageMap = langMapEng;
  } else {
    return languageMap = langMapHun;
  }
}
