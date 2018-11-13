import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType {
  login,
  register,
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final mainReference = FirebaseDatabase.instance.reference();
  String _email;
  String _password;
  String _name;
  String _mobile;
  int groupValue;
  Location _location = new Location();
  bool _permission = false;

  Map<String, double> location;

  String usertype;

  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          String userId =
              await auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
        } else {
          String userId =
              await auth.createUserWithEmailAndPassword(_email, _password);
          final ref = FirebaseDatabase.instance.reference();

          _permission = await _location.hasPermission();
          location = await _location.getLocation();
          var jsondata = {
            "email": _email,
            "password": _password,
            "name": _name,
            "mobile": _mobile,
            "usertype": usertype,
            "latitude": location["latitude"],
            "longitude": location["longitude"]
          };
          ref.child('users').push().set(jsondata);

          Firestore.instance.collection('users').add(jsondata);
          print('Registered user: $userId');
        }
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Find Me Tutor'),
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildInputs() + buildSubmitButtons(),
              ),
            )));
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(
          labelText: 'Email',
          icon: const Icon(Icons.email),
          hintText: 'Enter a email address',
        ),
        validator: EmailFieldValidator.validate,
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(
          labelText: 'Password',
          icon: const Icon(Icons.lock),
          hintText: 'Enter a Password',
        ),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        onSaved: (value) => _password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          key: Key('signIn'),
          child: Text('Login', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        TextFormField(
          key: Key('name'),
          decoration: InputDecoration(
            icon: const Icon(Icons.person),
            hintText: 'Enter your first and last name',
            labelText: 'Name',
          ),
          obscureText: false,
          onSaved: (value) => _name = value,
        ),
        TextFormField(
          key: Key('mobile number'),
          decoration: InputDecoration(
            icon: const Icon(Icons.phone),
            hintText: 'Enter a phone number',
            labelText: 'Phone',
          ),
          obscureText: false,
          onSaved: (value) => _mobile = value,
        ),
        new Row(children: [
          new Text(
            "You're a :",
            style: TextStyle(fontSize: 20.0),
          ),
          Radio(
            value: 1,
            groupValue: groupValue,
            onChanged: (int utype) => something(utype),
          ),
          Text("Tutor"),
          Radio(
            value: 2,
            groupValue: groupValue,
            onChanged: (int utype) => something(utype),
          ),
          Text("Student"),
        ]),
        RaisedButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child:
              Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        ),
      ];
    }
  }

  void something(int utype) {
    setState(() {
      if (utype == 1) {
        groupValue = 1;
        usertype = "Tutor";
      } else if (utype == 2) {
        groupValue = 2;
        usertype = "Student";
      }
    });
  }
}
