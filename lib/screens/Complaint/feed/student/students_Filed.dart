import 'package:e_complaint_box/global_widgets/loding_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import '../../../../global/global.dart';
import '../../../../widgets/dialogs/complaintDialog.dart';
import '../../../../widgets/cards/feedCard.dart';

GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class Filed extends StatefulWidget {
  const Filed({super.key});

  @override
  _FiledState createState() => _FiledState();
}

class _FiledState extends State<Filed> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Padding(
              padding:
                  EdgeInsets.only(right: 20, left: 20, top: 150, bottom: 0),
              child: ComplaintList()),
          Stack(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.035,
                    color: const Color(0xFF181D3D),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: (Responsive.isSmallScreen(context))
                        ? MediaQuery.of(context).size.height * 0.8
                        : MediaQuery.of(context).size.height * 0.2,
                    child: ClipPath(
                        clipper: CurveClipper(),
                        child: Container(
                          //constraints: BoxConstraints.expand(),
                          color: const Color(0xFF181D3D),
                        )),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (ZoomDrawer.of(context)!.isOpen()) {
                            ZoomDrawer.of(context)!.close();
                          } else {
                            ZoomDrawer.of(context)!.open();
                          }
                        },
                        icon: const Icon(Icons.menu, color: Colors.white),
                      ),
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/splash.png'),
                        radius: 25.0,
                      ),
                      const SizedBox(
                        width: 35.0,
                      ),
                      const Text(
                        'ASComplaints',
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white,
                          fontFamily: 'Amaranth',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Text('Complaints Filed',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: (30 * MediaQuery.of(context).size.height) /
                              1000)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////

// code for the upper design of appbar

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      // set the "current point"
      ..addArc(Rect.fromLTWH(0, 0, size.width / 2, size.width / 3), pi, -1.57)
      ..lineTo(9 * size.width / 10, size.width / 3)
      ..addArc(
          Rect.fromLTWH(
              size.width / 2, size.width / 3, size.width / 2, size.width / 3),
          pi + 1.57,
          1.57)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.width / 6);
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

///////////////////////// filed complaints execution //////////////////////////////////

var user = FirebaseAuth.instance.currentUser;

class ComplaintList extends StatefulWidget {
  const ComplaintList({super.key});

  @override
  _ComplaintListState createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<String>?>.value(
      value: getComplaintId,
      initialData: const ["You didn't filed any complaint"],
      child: const ComplaintTile1(),
    );
  }
}

List<String> getComplaints(DocumentSnapshot snapshot) {
  print(snapshot.data());
  return List.from(snapshot['list of my filed Complaints']);
}

Stream<List<String>?> get getComplaintId {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get()
      .then((snapshot) {
    try {
      return getComplaints(snapshot);
    } catch (e) {
      print(e);
      return null;
    }
  }).asStream();
}

class ComplaintTile1 extends StatefulWidget {
  const ComplaintTile1({super.key});

  @override
  _ComplaintTile1State createState() => _ComplaintTile1State();
}

class _ComplaintTile1State extends State<ComplaintTile1> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> user) {
          if (user.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingDialogWidget(
                message: 'Loading,',
              ),
            );
          }
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: LoadingDialogWidget(message: 'Loading,'));
                }
                List<Widget> currentresolved = [];
                for (var doc in snapshots.data!.docs) {
                  if (doc['status'] != 'Solved' &&
                      doc['uid'] == user.data!['uid']) {
                    currentresolved.add(ComplaintOverviewCard(
                      title: doc["title"],
                      onTap: ComplaintDialog(doc.id),
                      email: doc['email'],
                      filingTime: doc['filing time'],
                      fund: doc['fund'],
                      consults: doc['consults'],
                      category: doc["category"],
                      description: doc["description"],
                      status: doc["status"],
                      upvotes: doc['upvotes'],
                      id: doc.id,
                    ));
                  }
                }
                currentresolved.add(Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 40,
                          color: Color(0xFF36497E),
                        ),
                        Text(
                          "You're All Caught Up",
                          style: Theme.of(context).textTheme.headline6,
                        )
                      ],
                    )));
                return ListView(
                  children: currentresolved,
                );
              });
        });
  }
}
