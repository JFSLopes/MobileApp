import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentScreen extends StatefulWidget {
  @override
  final String postId;
  const CommentScreen({super.key, required this.postId});
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  String _name = "";
  Map<String, bool> _showReplyField = {};
  Map<String, TextEditingController?> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    loadProfileName();
    FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').get().then((querySnapshot) {
      querySnapshot.docs.forEach((comment) {
        _replyControllers[comment.id] = TextEditingController();
      });
    });
  }

  Widget _buildReplies(String commentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').doc(commentId).collection('replies').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final replies = snapshot.data?.docs ?? [];
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: replies.map<Widget>((replyDoc) {
              final replyData = replyDoc.data() as Map<String, dynamic>?;
              final replyUser = replyData?['user'] as String?;
              final replyText = replyData?['reply'] as String?;
              final timestamp = replyData?['timestamp'] as Timestamp?;
              final formattedTimestamp = timestamp != null ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate()) : 'No timestamp';

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyText ?? 'No reply',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            replyUser ?? 'Unknown user',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            formattedTimestamp ?? 'No time',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> loadProfileName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String fname = userSnapshot.data()?['firstName'] ?? '';
      String lname = userSnapshot.data()?['lastName'] ?? '';
      _name = "$fname $lname";
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> _submitReply(String commentId, String reply) async {
    try {
      if (reply.isNotEmpty) {
        await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').doc(commentId).collection('replies').add({
          'reply': reply,
          'timestamp': Timestamp.now(),
          'user': _name,
        });
        _showDialog('Reply posted successfully!');
        setState(() {
          _showReplyField[commentId] = false;
        });
      } else {
        _showDialog('Reply cannot be empty!');
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> _submitComment(String comment) async {
    try {
      if (comment.isNotEmpty) {
        await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
          'comment': comment,
          'timestamp': Timestamp.now(),
          'user': _name,
        });
        _showDialog('Comment posted successfully!');
      } else {
        _showDialog('Comment cannot be empty!');
      }
    } catch (e) {
      // Handle errors
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
        title: const Text('Comments'),
      backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final comments = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData = comments[index].data() as Map<String, dynamic>?;
                    final commentId = comments[index].id;
                    final commentUser = commentData?['user'] as String?;
                    final commentText = commentData?['comment'] as String?;
                    final timestamp = commentData?['timestamp'] as Timestamp?;
                    final formattedTimestamp = timestamp != null ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate()) : 'No timestamp';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(commentText ?? 'No comment'),
                            subtitle: Row(
                              children: [
                                Text(commentUser ?? 'Unknown user',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(' · ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(formattedTimestamp ?? 'No time',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showReplyField[commentId] = true;
                                });
                              },
                              child: Text('Reply'),
                            ),
                          ),
                        ),
                        if (_showReplyField[commentId] ?? false)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replyControllers[commentId],
                                    decoration: InputDecoration(
                                      hintText: 'Enter your reply',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    String reply = _replyControllers[commentId]?.text ?? '';
                                    _submitReply(commentId, reply);
                                    _replyControllers[commentId]?.clear();
                                  },
                                  icon: Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                        _buildReplies(commentId),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your comment',
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  String comment = commentController.text;
                    _submitComment(comment);
                    commentController.clear();
                },
                icon: const Icon(Icons.send_sharp, size: 30, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}