/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '/services/http/auth_service.dart';
import '/services/local_db/local_db.dart';
import '/view/dashboard/dashboard.dart';
import '/view/utils/assets.dart';
import '/view/utils/colors.dart';
import '/view/utils/snackbar.dart';
import '/view/utils/loading.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  GlobalKey usernameKey = GlobalKey();
  GlobalKey passwordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment(0.8, 1),
          //   colors: <Color>[
          //     Color(0xff2eb62c),
          //     Color(0xff57c84d),
          //     Color(0xff83d475),
          //     Color(0xffabe098),
          //     Color(0xffc5e8b7),
          //   ],
          //   tileMode: TileMode.mirror,
          // ),
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(ImageAssets.loginBackground))),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ImageAssets.logo,
                      height: 140,
                      width: 140,
                    ),
                    TextFormField(
                      key: usernameKey,
                      controller: username,
                      onEditingComplete: () {
                        setState(() {
                          FocusManager.instance.primaryFocus!.unfocus();
                        });
                      },
                      onTapOutside: (event) {
                        setState(() {
                          FocusManager.instance.primaryFocus!.unfocus();
                        });
                      },
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: "Username",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Iconsax.user),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: greenColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter username";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      key: passwordKey,
                      onEditingComplete: () {
                        setState(() {
                          FocusManager.instance.primaryFocus!.unfocus();
                        });
                      },
                      onTapOutside: (event) {
                        setState(() {
                          FocusManager.instance.primaryFocus!.unfocus();
                        });
                      },
                      controller: password,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Iconsax.key),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: greenColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordvisable = !passwordvisable;
                            });
                          },
                          icon: Icon(passwordvisable
                              ? Iconsax.eye_slash
                              : Iconsax.eye),
                          color: const Color(0xff686868),
                        ),
                      ),
                      obscureText: passwordvisable,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        login();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  login() async {
    if (formKey.currentState!.validate()) {
      if (username.text.isNotEmpty && password.text.isNotEmpty) {
        try {
          futureLoading(context);
          await AuthService()
              .checkLogin(username: username.text, password: password.text)
              .then((value) {
            if (value["head"]["code"] == 200) {
              Navigator.pop(context);
              LocalDBConfig()
                  .newUserLogin(
                      userId: value["head"]["msg"]["user_id"],
                      name: value["head"]["msg"]["user_name"],
                      email: value["head"]["msg"]["email"])
                  .then((onValue) {
                showSnackBar(context,
                    content: "Login Successfully", isSuccess: true);
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardView()));
                });
              });
            } else {
              Navigator.pop(context);
              showSnackBar(context,
                  content: value["head"]["msg"], isSuccess: false);
            }
          });
        } catch (e) {
          showSnackBar(context, content: e.toString(), isSuccess: false);
        }
      } else {
        showSnackBar(context,
            content: 'Please enter Username and Password', isSuccess: false);
      }
    }
  }

  bool passwordvisable = true;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  var formKey = GlobalKey<FormState>();
}
