import 'package:chat_app_firebase/helper/helper_function.dart';
import 'package:chat_app_firebase/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//  login
  Future loginWithUserNamedandPassword(String email, String password) async {
    try {
      final user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        // await DatabaseServices(uid: user.user!.uid).updateUserData(email, password);
        return true;
      } else {}
    } on FirebaseException catch (e) {
      // print(e);
      return e.message;
    }
  }

//register
  Future registerUserEmailandPassword(
      String fullname, String email, String password) async {
    try {
      final user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        await DatabaseServices(uid: user.user!.uid)
            .savingUserData(fullname, email);
        return true;
      } else {}
    } on FirebaseException catch (e) {
      // print(e);
      return e.message;
    }
  }

//signout
  Future signOut() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserNameSF("");
      await HelperFunction.saveUserEmailSF("");
      await firebaseAuth.signOut();
    } catch (e) {}
  }
}
