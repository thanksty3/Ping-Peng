import 'package:flutter/material.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/utils/utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await DatabaseService().searchUsers(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchNavAppBar(),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.orange,
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.orange,
                ),
                hintText: 'Search for users...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              onChanged: (query) {
                _searchUsers(query.trim());
              },
            ),
          ),
          // Search results
          _isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  flex: 2,
                  child: _searchResults.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user['profilePictureUrl'] !=
                                        null
                                    ? NetworkImage(user['profilePictureUrl'])
                                    : null,
                                child: user['profilePictureUrl'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                user['username'],
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 20),
                              ),
                              subtitle: Text(
                                '${user['firstName']} ${user['lastName']}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                // Navigate to user profile
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Account(userId: user['userId']),
                                  ),
                                );
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
