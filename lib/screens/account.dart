import 'package:flutter/material.dart';
import 'package:ping_peng/utils.dart';
import 'package:ping_peng/screens/edit_info.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountNavAppBar(),
      backgroundColor: Colors.white12,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //profile picture that is fetched from firebase storage
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 100,
                )
              ],
            ),
            const SizedBox(height: 10),

            //name and username fetched from firebase cloud
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('firstName lastName',
                        style: TextStyle(fontFamily: 'Jua', fontSize: 25)),
                    Text('@username',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),

            //edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditInfo()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            //interests and quote fetched from firebase cloud
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //peng quote
                  Column(
                    children: [
                      Text('Peng Quote',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                              colors: [Colors.orange, Colors.black87],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        ),
                        child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            child: const Text(
                              '"My Peng Quote"',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            )),
                      )
                    ],
                  ),
                  const SizedBox(width: 10),

                  //interests
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        'Interests',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                                colors: [Colors.orange, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        width: 200,
                        child: Wrap(
                          children: [
                            Chip(
                              backgroundColor: Colors.white,
                              label: Text(
                                'interest',
                                style:
                                    TextStyle(fontFamily: 'Jua', fontSize: 15),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const AccountNavBottomNavigationBar(),
    );
  }
}
