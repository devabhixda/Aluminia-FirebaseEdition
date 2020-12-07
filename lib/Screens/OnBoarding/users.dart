import 'package:aluminia/Screens/OnBoarding/Education.dart';
import 'package:aluminia/Screens/OnBoarding/ProfilePage.dart';
import 'package:aluminia/Services/auth.dart';
import 'package:aluminia/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersListState createState() => _UsersListState();
}

int count = 0;

class _UsersListState extends State<UsersList> {
  double w, h;

  Auth auth = new Auth();
  void initState() {
    super.initState();
    setLogin();
  }

  setLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', true);
  }

  List<String> list;

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Aluminia",
          style: GoogleFonts.comfortaa(color: blu, fontSize: 32),
        ),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 0.05 * w),
              child: CircleAvatar(
                child: Icon(Icons.person),
                backgroundColor: blu,
              ))
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: users.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
              // itemCount: 10,
              // return  itemBuilder: (BuildContext context, int index) {
              {
                count++;
                bool tapped = false;
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                          width: 0.9 * w,
                          height: 0.15 * h,
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => UserList()));
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                            // picUrl: document.data()['picture']
                                            )
                                        // Profile(
                                        //     picUrl: document
                                        //         .data()['picture'])
                                        ));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                                color: Colors.white,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              width: 70,
                                              height: 70,
                                              child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.green,
                                                  backgroundImage: NetworkImage(
                                                      // "https://static.jobscan.co/blog/uploads/linkedin-profile-picture-1280x720.jpg")),
                                                      document
                                                          .data()['picture']))),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  document.data()['name'],
                                                  style: GoogleFonts.comfortaa(
                                                      color: blu, fontSize: 18),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(document.data()['gender'],
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ])
                                        ],
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: FlatButton(
                                            onPressed: () {
                                              auth.addConnection(document.id);

                                              // print(cardsValue[count]);
                                            },
                                            color: blu,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                              "Connect",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                );
              }
            }).toList());
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}