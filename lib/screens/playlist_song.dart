import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:spotify/model/song_model.dart';
import 'package:spotify/model/stream_model.dart';
import 'package:http/http.dart' as http;

class PlaylistSongs extends StatefulWidget {
  final PlaylistId;
  final PlaylistName;
  PlaylistSongs({this.PlaylistId, this.PlaylistName});
  @override
  _PlaylistSongsState createState() => _PlaylistSongsState();
}

class _PlaylistSongsState extends State<PlaylistSongs> {
  Future<List<dynamic>> futureSong;
  Future<List<dynamic>> fetchSong() async {
    final response = await http.get(
        "https://ancient-spire-46177.herokuapp.com/tracks/myplaylist/tracks/${widget.PlaylistId}");
    // print(jsonDecode(response.body)[0]['playlist_name']);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
      // return SongData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    futureSong = fetchSong();
    print(widget.PlaylistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.black54,
          title: Text('${widget.PlaylistName}',
              style: GoogleFonts.raleway(textStyle: TextStyle(fontSize: 30))),
        ),
        body: FutureBuilder(
            future: futureSong,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return SongCard(
                        image: Random().nextInt(7) + 1,
                        sname: snapshot.data[index]['name'],
                        songId: snapshot.data[index]['track'],
                        artistName: snapshot.data[index]['artist_name'],
                      );
                    });
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "${snapshot.error}",
                ));
              }
              // By default, show a loading spinner.
              return Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Spacer(),
                    CircularProgressIndicator(),
                    Spacer(),
                  ],
                ),
              );
            }));
  }
}

class SongCard extends StatelessWidget {
  final image;
  final String sname;
  final String songId;
  final String artistName;

  SongCard({this.image, this.sname, this.songId, this.artistName});
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<StreamModel>(context, listen: false);
    return InkWell(
      onTap: () {
        model.inString.add(Song(uid: songId, Name: sname, Artist: artistName));
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => PlayPage(
        //           songInfo: Song(Name: sname,Artist: artistName,uid: songId),
        //             )));
      },
      child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/p$image.jpg",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$sname",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$artistName",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  )
                ],
              ),
            ),
            Spacer(),
            Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                Text(
                  "200",
                  style: TextStyle(color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
