import 'package:flutter/material.dart';
import 'package:ping_peng/utils.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavAppBar(),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Other Users' Profile Picture
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                  ),
                ],
              ),
              const SizedBox(height: 5),

              //Other Users' Name and Username
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'firstName lastName',
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jua',
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@username',
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),

              //Buttons for adding user as a friend or go to next card
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            /*send friend request to show up in user's notifications and switch to the next user, displaying their profile picture and info*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Send Friendship P!ng',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            /*cycle to next user, displaying their information and profile picture*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),

              //Other Users' Peng Quote and Interests
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Other Users' Peng Quote
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Peng Quote',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jua',
                                color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              '"Peng Quote"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Other Users' Interests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Interests',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jua',
                                color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )
            ],
          )),
      bottomNavigationBar: const HomeNavBottomNavigationBar(),
    );
  }
}
