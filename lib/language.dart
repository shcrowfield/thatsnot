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
  'LobbyIsFull': 'Lobby is Full',
  'Orange': 'Orange',
  'Purple': 'Purple',
  'Black': 'Black',
  '1' : '1',
  '2' : '2',
  '3' : '3',
  '4' : '4',
  '5' : '5',
  '6' : '6',
  '7' : '7',
  '8' : '8',
  '9' : '9',
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
  'LobbyIsFull': 'A lobbi megtelt',
  'Orange': 'Narancssárga',
  'Purple': 'Lila',
  'Black': 'Fekete',
  '1' : '1',
  '2' : '2',
  '3' : '3',
  '4' : '4',
  '5' : '5',
  '6' : '6',
  '7' : '7',
  '8' : '8',
  '9' : '9',
};
final Map<String, String> langMapTur = {
  'Back': 'Geri',
  'CreateLobby': 'Lobi oluştur',
  'ActiveLobbies': 'Aktif lobiler',
  'Results': 'Sonuçlar',
  'SignIn': 'Giriş yap',
  'SignOut': 'Çıkış yap',
  'GoogleSignOut': 'Google çıkış',
  'GoogleSignIn': 'Google giriş',
  'Rules': 'Kurallar',
  'Next': 'Sonraki',
  'NumberOfPlayers': 'Oyuncu sayısı:',
  'LobbyName': 'Lobinin adı',
  'Nickname': 'Rumuz',
  'EnterNickname': 'Rumuz gir',
  'Players': 'Oyuncular',
  'Ready': 'Hazır',
  'Allow to Enter': 'Girilebilir',
  'LobbyIsFull': 'Lobi dolu',
  'Orange': 'Turuncu',
  'Purple': 'Mor',
  'Black': 'Siyah',
  '1' : '1',
  '2' : '2',
  '3' : '3',
  '4' : '4',
  '5' : '5',
  '6' : '6',
  '7' : '7',
  '8' : '8',
  '9' : '9',
};

Map<String, String> languageMap = langMapHun;
String lang = 'Hun';

void setLanguage(String langValue) {
  lang = langValue;
  languageMap = changeLanguageMap();
}

Map<String, String> changeLanguageMap() {
  if (lang == 'Eng') {
    return languageMap = langMapEng;
  } else if (lang == 'Tur') {
    return languageMap = langMapTur;
  } else {
    return languageMap = langMapHun;
  }
}
