import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_complaint_box/global_widgets/loding_dialog.dart';
import 'package:e_complaint_box/widgets/dialogs/admin/admin_dialog.dart';
import '../../../../global/global.dart';
import '../../../../widgets/cards/feedCard.dart';

var user = FirebaseAuth.instance.currentUser;

GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class AdminPending extends StatefulWidget {
  const AdminPending({super.key});

  @override
  _AdminPendingState createState() => _AdminPendingState();
}

class _AdminPendingState extends State<AdminPending>
    with SingleTickerProviderStateMixin {
  CollectionReference complaints =
      FirebaseFirestore.instance.collection('complaints');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  right: 20, left: 20, top: 150, bottom: 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: complaints.snapshots(),
                builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, user) {
                    if (user.connectionState == ConnectionState.waiting) {
                      return const LoadingDialogWidget(
                        message: "Loading...\n",
                      );
                    }
                    List<Widget> list = snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                      if ((document['category'] ==
                              user.data!['category']) &&
                          (document['status'] == 'Pending' ||
                              document['status'] == 'In Progress')) {
                        return ComplaintOverviewCard(
                          title: document['title'],
                          onTap: AdminDialog(document.id),
                          email: document['email'],
                          filingTime: document['filing time'],
                            fund: document['fund'],
                                  consults: document['consults'],
                          category: document['category'],
                          description: document['description'],
                          status: document['status'],
                          upvotes: document['upvotes'],
                          id: document.id,
                        );
                      }
                      return const SizedBox(width: 0.0, height: 0.0);
                    }).toList();
                    list.add(Container(
                        padding: const EdgeInsets.all(10),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 40,
                              color: Color(0xFF36497E),
                            ),
                            Text("You're All Caught Up",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54))
                          ],
                        )));

                    return ListView(children: list);
                  });
                },
              )),
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
                  const Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/splash.png'),
                        radius: 25.0,
                      ),
                      SizedBox(
                        width: 35.0,
                      ),
                      Text(
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
                  Text('Complaints Pending',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: (30 * MediaQuery.of(context).size.height) /
                              1000)),
                ],
              ),
            ],
          )
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
  bool shouldReclip(oldCliper) => false;
}
