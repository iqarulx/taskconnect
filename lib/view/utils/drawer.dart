/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/view/dashboard/dashboard.dart';
import '/view/insights/insights.dart';
// import '/view/terms/privacy_policy.dart';
// import '/view/terms/terms_and_conditions.dart';
import '/view/utils/assets.dart';
import '/view/utils/colors.dart';
import '/view/utils/logout.dart';

SafeArea drawer(BuildContext context, String name, String email,
    bool showInsights, String currentVersion) {
  return SafeArea(
    child: Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.black,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            listOptions(name, email, context, showInsights),
            // policyOption(context),
            logoutButton(context),
            appVersion(currentVersion, context),
          ],
        ),
      ),
    ),
  );
}

Padding policyOption(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onDoubleTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const PrivacyPolicy(),
            //   ),
            // );
          },
          child: Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
          ),
        ),
        GestureDetector(
          onDoubleTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const TermsAndConditions(),
            //   ),
            // );
          },
          child: Text(
            'Terms and Conditions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
          ),
        ),
      ],
    ),
  );
}

Padding appVersion(String currentVersion, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onDoubleTap: () {},
      child: Text(
        'App Version: $currentVersion',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
      ),
    ),
  );
}

Expanded listOptions(
    String name, String email, BuildContext context, bool showInsights) {
  return Expanded(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(ImageAssets.user),
              radius: 25,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Colors.grey,
          indent: 10,
          endIndent: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Menu",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardView()));
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.home,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Home",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (showInsights)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const InsightsView()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.graph,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Insights",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

GestureDetector logoutButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(context);
      await logout(context);
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 40,
      width: double.infinity,
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.logout,
              color: Colors.white,
              size: 17,
            ),
            SizedBox(width: 5),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
