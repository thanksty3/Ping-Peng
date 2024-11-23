// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/utils.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    DatabaseService dbService = DatabaseService();
    List<Map<String, dynamic>> results = await dbService.searchUsers(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: SearchNavAppBar(),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchUsers(value);
              },
              cursorColor: Colors.orange,
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                  hintText: 'Search by username...',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange))),
            ),
          ),

          // Search Results
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 50,
                          backgroundImage: user['profilePictureUrl'] != null
                              ? NetworkImage(user['profilePictureUrl'])
                              : AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                        ),
                        title: Text(
                          '${user['firstName']} ${user['lastName']}',
                          style: TextStyle(color: Colors.orange, fontSize: 20),
                        ),
                        subtitle: Text(
                          user['username'],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          // Navigate to the user's profile (Implement this)
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: SearchNavBottomNavigationBar(),
    );
  }
}
