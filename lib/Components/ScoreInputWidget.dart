import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golf_app/Utils/Providers/MatchProvider.dart';
import 'package:provider/provider.dart';
import '../Utils/constants.dart';
import '../Utils/Match.dart';

class ScoreInputWidget extends StatelessWidget {

  final ValueChanged<Match> onMatchChanged;
  final String hintText;
  final _scoreController = TextEditingController();
  final int playerId;
  Match match;
 
  ScoreInputWidget({
    Key? key,
    required this.onMatchChanged,
    required this.match,
    required this.hintText,
    required this.playerId,
  }) : super(key: key);

  Widget build(BuildContext context){
    //final matchProvider = context.read<MatchProvider>();
    return TextFormField(
      showCursor: false,
      textAlign: TextAlign.center, 
      keyboardType: TextInputType.number,
      style: Theme.of(context).primaryTextTheme.headline2,
      controller: _scoreController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).primaryTextTheme.headline2,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 3, color: Colors.grey),
        )
      ),

      onChanged: (string) async {
        print(_scoreController.text);
        Match m = await match.postHoleScore(playerId, int.parse(_scoreController.text));
        onMatchChanged(m);
      },
    );
  }
}
