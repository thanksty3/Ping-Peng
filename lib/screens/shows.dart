import 'package:flutter/material.dart';
import 'package:ping_peng/utils.dart';

class Shows extends StatelessWidget {
  const Shows({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShowsNavAppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 27),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'firstName LastName',
                    style: TextStyle(
                      fontFamily: 'Jua',
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '@username',
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ])
              ],
            ),
            const Expanded(
              child: FittedBox(
                child: Image(image: AssetImage('assets/images/P!ngPeng.png')),
              ),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.favorite_border)),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: const ShowsNavBottomNavigationBar(),
    );
  }
}
