import 'package:flutter/material.dart';
import 'package:thatsnot/pages/start_screen.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  _onRulesNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Center(
          child: Column(children: [
            const SizedBox(height: 50),
            TextButton.icon(
              onPressed: () {
                _onRulesNext();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Vissza'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
            const Text(
              'Játékszabályok',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Aligning text properly
                    children: [
                      Text(
                        'A főmenüben válassz, hogy új lobbit szeretnél-e létrehozni vagy belépni egy már létező lobbiba. ',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10), // Add spacing between text blocks
                      Text(
                        'Lobbi létrehozása',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'A Lobbi létrehozása menüben meg kell adnod egy Becenevet, amit a játék közben szeretnél használni. Ezután a lobbinak kell megadnod egy nevet, majd kiválasztani hány emberrel szeretnél játszani. A "Tovább" gombra kattinta bekerülsz a lobbiba.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lobbihoz csatlakozás',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'A Lobbihoz csatlakozás menüben meg kell adnod egy Becenevet, amit a játék közben szeretnél használni. Ezután az általad választott lobbi nevére kattintva bekerülsz a lobbiba.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'A játéktér felépítése',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'A játéktér alsó részén láthatod a kezedben tartott lapokat. A kártyáktól balra a "Hazug" gombot, jobbra a "Passz" gombot találod. A játéktér közepén találhatod a húzópaklit valamin a játék jelenlegi állását. A játéktér felső részén a pontjaid valamint a "Kilépés" gomb található.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'A játék menete',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'A játékban 95 lap található. 3x9 Narancssárga, 3x9 Lila, 3x9 Fekete, valamint 4 színjoker, 4 számjoker és 6 antijoker. A játék során a játékosok sorban leraknak egy-egy lapot a dobópakliba. Ennek van pár zabája:',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '1. Új színsort kezdeni csak 1-2-3 lappal lehet.',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '2. Az elzőnél csak nagyobb lapot szabad lerakni, de nem muszáj sorban.',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '3. Ha van már a dobópakliban lap csak azzal megegyező színűt lehet lerakni.',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '4. 9-es után lehet új színsort kezdeni 1-2-3 lappal.',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                          'Viszont itt jön a csavar. Ezt az egészet "Bemondásos alapon" működik, nem kell igaznak lennie, a kártyákat is fejjel lefelé teszitek le az asztalra.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(
                          ' A körödben, ha valaki nem hisz neked megkérdőjelezheti vagy a kártya színét vagy a számát. Ha igaza van, megkapja a dobópakliban lévő lapok dadrabszámát, mint pont. Ha nincs, te kapod ugyan ezt. Aki veszíti a "párbajt" kap két lapot a kezébe és ő kezdi az új kört. Ha nem szeretnél letenni lapot felhúzhatsz a húzópakliból.',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      Text(
                          'A sikerül az összes lapot letenned a kezedből kapsz +10 pontot és új 6 lapot, a játék folytatódik.',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      Text(
                          'Jokerek: A színjoker bármilyen színt képviselhet, a számjoker bármilyen számot. Az antijokerrel nem jó semmire, de ha a játék végén a kezedben van -10 pontot jelent.',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      Text(
                          'A játék akkor ér véget, ha elfogya húzópakli. A játékos végső pontja a játékos játék közben összegyűlytött pontjai mínusz a játék végén kézben maradt lapok száma, mínusz az antijoker.',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
