import 'dart:io';
import 'package:aluminia/client_secrets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imgur/imgur.dart' as imgur;

class Auth {
  FirebaseAuth auth = FirebaseAuth.instance;
  Stream<User> get authStateChanges => auth.authStateChanges();
  UserCredential userCredential;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final client = imgur.Imgur(imgur.Authentication.fromToken(imgurAuth));

  createAccount(String email, String password) async {
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
      await userCredential.user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
    } catch (e) {
      print(e);
    }
    return userCredential != null;
  }

  Future<void> addUser(String name, String dob, String gender, String imageUrl,
      String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');

    var firebaseUser = FirebaseAuth.instance.currentUser;
    var newId = firebaseUser.uid;
    return users
        .doc(newId)
        .set({
          'name': name,
          'email': email,
          'dob': dob,
          'picture': imageUrl,
          'gender': gender,
          'phone': phone
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addConnection(String id) async {
    User firebaseUser = FirebaseAuth.instance.currentUser;
    print(firebaseUser.uid);
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('requestSent')
        .doc(id)
        .set({});
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('requestReceived')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({});
    return users.doc(firebaseUser.uid).update({
      'connection': FieldValue.arrayUnion([id])
    });
  }

  Future<void> addEducation(String schoolName, String degree, String startDate,
      String endDate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print("uid");
    print(firebaseUser.uid);
    // return null;
    return users
        .doc(firebaseUser.uid)
        .set({
          'education': FieldValue.arrayUnion(
            [
              {
                'schoolName': schoolName,
                'degree': degree,
                'startDate': startDate,
                'endDate': endDate
              }
            ],
          ),
        }, SetOptions(merge: true))
        .then((value) => print("Education Added"))
        .catchError((error) => print("Failed to add education: $error"));
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  Future<void> addWork(String company, String designation, String startDate,
      String endDate) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print("uid");
    print(firebaseUser.uid);
    return users
        .doc(firebaseUser.uid)
        .set({
          'WorkHistory': FieldValue.arrayUnion(
            [
              {
                'company': company,
                'designation': designation,
                'startDate': startDate,
                'endDate': endDate
              }
            ],
          ),
        }, SetOptions(merge: true))
        .then((value) => print("Education Added"))
        .catchError((error) => print("Failed to add education: $error"));
  }

  Future<String> uploadImage(File _imageFile) async {
    print(_imageFile.hashCode);
    final ref = FirebaseStorage.instance
        .ref()
        .child('pfp')
        .child(_imageFile.hashCode.toString());
    if (_imageFile != null) {
      await ref.putFile(_imageFile).onComplete;
      return await ref.getDownloadURL();
    } 
    return "";
  }

  Future<bool> getUser(String email) async {
    bool existing;
    await users
        .where('email', isEqualTo: email)
        .get()
        .then((value) => value.size == 0 ? existing = false : existing = true);
    return existing;
  }

  addChatRoom(chatRoom, chatRoomId) async {
    firestore.collection("chatRoom").doc(chatRoomId).set(chatRoom)
      .catchError((e) {
        print(e);
      }
    );
  }

  getChats(String chatRoomId) async {
    return firestore.collection("chatRoom").doc(chatRoomId).collection("chats").orderBy('time').snapshots();
  }

  addMessage(String chatRoomId, chatMessageData) async{
    firestore.collection("chatRoom").doc(chatRoomId).collection("chats").add(chatMessageData)
      .catchError((e){
        print(e.toString());
      }
    );
    firestore.collection("chatRoom").doc(chatRoomId).update({
        "updatedAt": DateTime.now()
    }).catchError((e){
        print(e.toString());
      }
    );
  }

  getUserChats(String itIsMyName) async {
    return firestore.collection("chatRoom").where('users', arrayContains: itIsMyName).snapshots();
  }

  Future<String> getName(String uid) async{
    String name;
    await firestore.collection("users").doc(uid).get().then((val) => {
      name = val.data()['name']
    });
    return name;
  }
}
