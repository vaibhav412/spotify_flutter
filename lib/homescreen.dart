import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:spotify/model/song_model.dart';
import 'package:spotify/model/song_player.dart';
import 'package:spotify/model/stream_model.dart';
import 'package:spotify/screens/all_playlist.dart';
import 'package:spotify/screens/all_songs.dart';
import 'package:spotify/screens/bottom_panel.dart';
import 'package:spotify/screens/playlist.dart';
import 'package:spotify/screens/playpage.dart';
import 'package:spotify/service/auth.dart';

class HomeScreen extends StatefulWidget {
  final userId;
  HomeScreen({this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  int _selectedIndex = 0;
  AudioPlayer audioPlayer = new AudioPlayer();

  List<Widget> screens = [Songs(), Playlist()];
  var tabbarController;

  Future<void> signOut() async {
    final auth = Provider.of<Auth>(context, listen: false);

    try {
      auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<StreamModel>(context, listen: false);

    return StreamBuilder<Song>(
      stream: model.outString,
      builder: (context, snapshot) {
        return ChangeNotifierProvider(
          create: (context) => checkBool(),
          child: SlidingUpPanel(
            panel: snapshot.data == null
                ? Container()
                : PlayPage(
                    songInfo: snapshot.data,
                  ),
            minHeight: 60,
            maxHeight: MediaQuery.of(context).size.height,
            backdropEnabled: true,
            backdropOpacity: 0.5,
            parallaxEnabled: true,
            collapsed: snapshot.data == null
                ? Container(
                    color: Colors.black,
                  )
                : BottomPanel(songInfo: snapshot.data),
            body: Scaffold(
              backgroundColor: Colors.black54,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.black54,
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyPlaylist(userId: widget.userId),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'My Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "SignOut",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await signOut();
                    },
                  ),
                ],
                title: Text('Spotify',
                    style:
                        GoogleFonts.raleway(textStyle: TextStyle(fontSize: 40))
                    // style: Theme.of(context)
                    //     .textTheme
                    //     .headline4
                    //     .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNavigationRail(),
                          screens[_selectedIndex],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      backgroundColor: Colors.black54,
      minWidth: 1.0,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      groupAlignment: -0.1,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: GoogleFonts.raleway(
          textStyle: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
      unselectedLabelTextStyle: GoogleFonts.raleway(
          textStyle: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      // leading: Column(
      //   children: [
      //     Icon(
      //       Icons.playlist_play,
      //       color: Color(0xff0968B0),
      //     ),
      //     SizedBox(height: 5.0),
      //     RotatedBox(
      //       quarterTurns: -1,
      //       child: Text(
      //         'Your playlists',
      //         style:
      //         TextStyle(color: Color(0xff0968B0), fontWeight: FontWeight.bold),
      //       ),
      //     )
      //   ],
      // ),
      destinations: [
        NavigationRailDestination(
          icon: SizedBox.shrink(),
          label: RotatedBox(
            quarterTurns: -1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('All Songs'),
            ),
          ),
        ),
        NavigationRailDestination(
          icon: SizedBox.shrink(),
          label: RotatedBox(
            quarterTurns: -1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(' All Playlists'),
            ),
          ),
        )
      ],
    );
  }
}
