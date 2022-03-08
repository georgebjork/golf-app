

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:golf_app/Utils/MatchPlayerResult.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'package:golf_app/Components/PieChartStats.dart';
import 'package:golf_app/Components/PieChartStatsScoring.dart';
import 'package:golf_app/Components/Statscard.dart';
import 'package:golf_app/Utils/GamePlayerResult.dart';
import 'package:golf_app/Utils/Stat.dart';

import '../Components/CustomNavButton.dart';
import '../Components/GameSummarys.dart';
import '../Utils/Game.dart';
import '../Utils/Match.dart';
import '../Utils/Player.dart';
import '../Utils/Point.dart';
import '../Utils/Providers/ThemeProvider.dart';
import 'ViewMatch.dart';

class RoundSummary extends StatelessWidget {

  Match match;

  RoundSummary(this.match, {Key? key}) : super(key: key);


  //This will take in a game and display it to the screen
  Widget displayGameSummary(Game game) {
    //This switch statement will display the game based on the name of the game. Classes imported from GameSummarys
    switch(game.name) {
      case 'Skins': return DisplaySkins(match: match);
      case 'Nasseau' : return Container();
    }
    return Container();
  }


  Widget build(BuildContext context){

    final themeProvider = context.read<ThemeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        //leading: IconButton(icon: Platform.isAndroid ? const Icon(Icons.arrow_back) : const Icon(Icons.arrow_back_ios_new), color: Colors.black, onPressed: () => Navigator.pop(context)),
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Container(
        //padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(padding: const EdgeInsets.only(left: 20.0, right: 20.0), child: Text('Round Summary', style: Theme.of(context).primaryTextTheme.headline2)),
                  Container(padding: const EdgeInsets.only(left: 20.0, right: 20.0), child: Text(match.course.name, style: Theme.of(context).primaryTextTheme.headline4)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(text: 'View scorecard', width: double.infinity, color: context.read<ThemeProvider>().getRed(), onPressed: () {
                        Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop,  duration: const Duration(milliseconds: 500), child: ViewMatch(match: match)));
                    }),
                  ),
                  
                  //const SizedBox(height: 10),
                  
                 // const SizedBox(height: 10),

                  //Display Scores
                  Container(padding: const EdgeInsets.only(left: 20.0, right: 20.0), child: Text('Scores', style: Theme.of(context).primaryTextTheme.headline2)),
                  DisplayScores(match: match),

                  const SizedBox(height: 10),

                  //Display the game summarys 
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: match.games.map((e) => displayGameSummary(e)).toList()
                      ),

                      //Display Payouts
                      Container(padding: const EdgeInsets.only(left: 20.0, right: 20.0), child: Text('Payouts', style: Theme.of(context).primaryTextTheme.headline2)),
                      PayOuts(match: match)
                    ],
                  ),
                ],
              )
            ),
            

            //Finish button sent to the bottom of the screen
            Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
              color: Colors.transparent,
              child: CustomButton(
                onPressed: () => Navigator.pushNamed(context, '/Home'),
                width: double.infinity,
                text: 'Finish',
                color: HexColor("#A13333")
              ),
            ),
            const SizedBox(height: 20)

          ],
        ),
      ),  
     
    );
  }
}


class DisplayScores extends StatelessWidget {

  final Match match;

  const DisplayScores({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0), 
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: match.players.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black,
        ), 
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(match.getPlayerName(index), style: Theme.of(context).primaryTextTheme.headline3),
            subtitle: const Text('Tap to view stats', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10),),
            trailing: Text(
              "Gross: " + match.rounds[index].Score.toString() + "   " +
              "Net: " + match.rounds[index].Net.toString(),
              style: Theme.of(context).primaryTextTheme.headline3
            ),
            onTap: () => showBarModalBottomSheet(
              context: context, 
              expand: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ModalDisplayRoundStats(
                playerIndex: index, 
                match: match,
              )
            ),
          );
        }, 
      ),
    );
  }
}

class ModalDisplayRoundStats extends StatelessWidget {
  final Match match;
  final int playerIndex;

  const ModalDisplayRoundStats({Key? key, required this.match, required this.playerIndex}) : super(key: key);

  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
        children: <Widget> [
          const SizedBox(height: 30),
          //Player name
          Center(child: Text(match.players[playerIndex].name, style: Theme.of(context).primaryTextTheme.headline3)),
          
          //Score Distribution
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Statscard(
              chart: PieChartStatsScoring(round: match.rounds[playerIndex]), 
              title: 'Score Disribution', 
              color: Colors.grey[350],
              legend: [
                Legend(color: Colors.purple.shade100, name: 'Eagle'),
                Legend(color: Colors.lightGreen.shade600, name:'Birdie'),
                Legend(color: Colors.lightGreen.shade200, name:'Par'),
                Legend(color: Colors.orange.shade200, name:'Bogey'),
                Legend(color: Colors.grey.shade400, name:'Double'),
                Legend(color: Colors.grey.shade800, name:'Triple+'),      
              ],
            )
          ),

          //Fairways
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Statscard(
              chart: PieChartStats(
                stats: [
                  Stat(type: 'Hit', color: Colors.red, number: 8),
                  Stat(type: 'Missed Right', color: Colors.grey.shade500, number: 2),
                  Stat(type: 'Missed Left', color: Colors.grey.shade700, number: 4)
                ],
              ),
              title: 'Fairways',
              color: Colors.grey[350],
              legend: [
                const Legend(color: Colors.red, name: 'Hit'),
                Legend(color: Colors.grey.shade500, name:'Miss Right'),
                Legend(color: Colors.grey.shade700, name:'Miss Left'),
              ],
            ),
          ),

          //Greens
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Statscard(
              chart: PieChartStats(
                stats: [
                  Stat(type: 'Hit', color: Colors.green, number: 10),
                  Stat(type: 'Missed', color: Colors.grey, number: 4)
                ],
              ),
              title: 'Greens',
              color: Colors.grey[350],
              legend: const [
                Legend(color: Colors.green, name: 'Hit'),
                Legend(color: Colors.grey, name:'Missed'),
              ],
            ),
          )

        ] 
      ),
    ); 
  }  
}

//This will calculate and display all payouts
class PayOuts extends StatefulWidget {

  Match match;
  PayOuts({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  State<PayOuts> createState() => _PayOutsState();
}

class _PayOutsState extends State<PayOuts> {

  List<GamePlayerResult> gameResults = [];
  List<Player> players = [];
  List<MatchPlayerResult> matchResults = [];

  Map<Player, List<Pays>> payOuts = {};


  void calculatePayouts(){
    //set gpr to results
    gameResults = widget.match.gamePlayerResult;
    //set players
    players = widget.match.players;
    //set match results
    matchResults = widget.match.matchPlayerResult;

    //This will store all the payouts and key values will be players
    Map<Player, List<Pays>> payOuts = {};

    //We want to go through each player and grab their results
    for(int i = 0; i < players.length; i++){
      //This is the payee
      Player payee = players[i];
      //This is the winnings each player owes payee
      dynamic winnings = matchResults[i].winnings;

      //This will hold all the players who pay and how mucu
      List<Pays> playersWhoPay = [];

      for(int j = 0; j < players.length; j++){
        //Make sure its not the payee
        if(payee != players[j]){
          //Add to list
          playersWhoPay.add(Pays(pays: winnings, player: players[j]));
        }
      }
      //Add to map
      payOuts.addAll({payee : playersWhoPay});
    }
  

    print(payOuts);
  }

  @override
  void initState() {
    //We want to first calculate all payouts
    calculatePayouts();

    super.initState();

    
  }
  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text('Hello world')),);
  }
}

//This class will extened the player class and display how much a player owes someone
class Pays extends Player {
  dynamic pays;

  Pays({required this.pays, required Player player}) : super(player.id, player.firstName, player.lastName, player.name, null);

  @override
  String toString() {
    return '${name} pays: ' + pays.toString();
  }
}
