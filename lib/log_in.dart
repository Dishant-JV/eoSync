import 'dart:convert';

import 'package:e_o_sync/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ex.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  String errText = "";
  bool showLoading = false;
  List<LogInModel> lstLogIn = [];

  SetLogIn(String accountCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var a = preferences.setBool('isLogIn', true);
    print(a);
    preferences.setString('accountCode', accountCode);
  }

  getData(String name, String password) async {
    final response = await http.post(
        Uri.parse("http://3.110.105.180:8080/api/login"),
        body: jsonEncode({'username': name, 'password': password}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> logInMap = jsonDecode(response.body);
      lstLogIn.add(LogInModel.fromJson(logInMap));
      if (lstLogIn[0].statusCode == "401") {
        setState(() {
          errText = "User Not Found";
          showLoading = false;
          lstLogIn.clear();
        });
      } else if (lstLogIn[0].statusCode == "200") {
        setState(() {
          showLoading = false;
          usercontroller.clear();
          passcontroller.clear();
        });
        SetLogIn(lstLogIn[0].accountCode.toString());
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHome()));
      }
    }
  }

  final demos = GlobalKey<FormState>();
  TextEditingController usercontroller = new TextEditingController();
  TextEditingController passcontroller = new TextEditingController();
  FocusNode user = FocusNode();
  FocusNode pass = FocusNode();
  bool ispassvisible = false;
  bool? logIn;

  void checkLogIN() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    logIn = preferences.getBool('isLogIn')!;
    print(logIn);
    if (logIn == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHome()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogIN();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Center(
                  child: Image.asset(
                'assets/images/remove_logo.png',
                height: MediaQuery.of(context).size.height * 0.3,
              )),
              Text(
                errText,
                style: TextStyle(
                    color: Colors.red, fontFamily: 'RyeFonts', fontSize: 17),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text("Login ",
                    style: TextStyle(
                      color: Color(0xff343A40),
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                    )),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Form(
                key: demos,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: usercontroller,
                          focusNode: user,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter User Name";
                            }
                          },
                          textInputAction: TextInputAction.go,
                          onEditingComplete: () {
                            setState(() {
                              FocusScope.of(context).requestFocus(pass);
                            });
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Color(0xff343A40))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: passcontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter password";
                            }
                          },
                          focusNode: pass,
                          obscureText: ispassvisible == true ? false : true,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    ispassvisible = !ispassvisible;
                                  });
                                },
                                icon: ispassvisible
                                    ? Icon(
                                        Icons.visibility,
                                        color: Color(0xff343A40),
                                      )
                                    : Icon(
                                        Icons.visibility_off,
                                        color: Color(0xff343A40),
                                      ),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Color(0xff343A40))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      showLoading == false
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  showLoading = true;
                                });
                                if (demos.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  getData(
                                      usercontroller.text, passcontroller.text);
                                }
                              },
                              child: Container(
                                child: Text("SIGN IN",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 17.5,letterSpacing: 2),),
                                alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Color(0xff343A40),
                                      borderRadius: BorderRadius.circular(5)),
                                  width: double.infinity,
                              height: 50,),
                            )
                          : CircularProgressIndicator(
                              color: Color(0xff343A40),
                            )
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}
