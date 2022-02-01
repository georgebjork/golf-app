import 'package:flutter/material.dart';
import 'package:golf_app/Components/ScoreInputWidget.dart';
import 'package:golf_app/Utils/Providers/MatchProvider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../Components/NavWidget.dart';

class EnterScore extends StatefulWidget {

  EnterScoreState createState() => EnterScoreState();
}

class EnterScoreState extends State<EnterScore> {

  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.match.course.name, style: Theme.of(context).primaryTextTheme.headline3),
                const SizedBox(height: 5,),
                Text(provider.displayCurrentHole(), style: Theme.of(context).primaryTextTheme.headline2),
                Text(provider.displayHoleDetails(), style: Theme.of(context).primaryTextTheme.headline4),
                const SizedBox(height: 10,),
        
                Expanded(
                  child: DisplayPlayerScores(),
                ),
        
                NavWidget(
                  btn1text: 'Prev',
                  btn1onPressed: () => provider.prevHole(),
                  btn2text: 'Next',
                  btn2onPressed: () => provider.nextHole(),
                  btn3text: 'Cancel',
                  btn3onPressed: () {}
                ),
                
                const SizedBox(height: 30)
              ]
            ),
          );
        }),
    );
  }
}

class DisplayPlayerScores extends StatefulWidget {

  DisplayPlayerScoresState createState() => DisplayPlayerScoresState();
}

class DisplayPlayerScoresState extends State<DisplayPlayerScores> {
  Widget build(context){
    return Container(
      child: Consumer<MatchProvider> (
        builder: (context, provider, child) {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            shrinkWrap: true, 
            itemCount: provider.match.players.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Text(provider.match.players[index].firstName),
                title: Text(provider.match.rounds[index].HoleScores[provider.currentHole].score.toString()),
                onTap: () => showBarModalBottomSheet(
                  context: context, 
                  expand: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ModalData(currentIndex: index)
                )
              );
            },
          );
        }
      ),
    );
  }
}


class ModalData extends StatefulWidget{

  final int currentIndex;

  ModalData({Key? key, required this.currentIndex}) : super(key: key);

  ModalDataState createState() => ModalDataState();

 
}

class ModalDataState extends State<ModalData> {
   Widget build(context){
     return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 10),
      child: Consumer<MatchProvider>(
        builder:(context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter Score", style: Theme.of(context).primaryTextTheme.headline2),

              //This will be to enter the gross score since we will always want that.
              Row(
                children: [
                  SizedBox(height: 60,),
                  Text('Gross Score: ', style: Theme.of(context).primaryTextTheme.headline3),
                  
                  Expanded(child: Center()),
        
                  Container(width: 50, height: 30, child: ScoreInputWidget(
                    hintText: provider.match.rounds[widget.currentIndex].HoleScores[provider.currentHole].score.toString(),
                    holeId: provider.currentHole+1,
                    playerId: provider.match.players[widget.currentIndex].id,
                    matchId: provider.match.id,
                  ))
                ],
              )
            ],
          );
        })
    );
   }
}

