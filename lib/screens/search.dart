import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/screens/account.dart';

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
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
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
                              title: Text(user['username']),
                              subtitle: Text(
                                  '${user['firstName']} ${user['lastName']}'),
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
    );
  }
}
