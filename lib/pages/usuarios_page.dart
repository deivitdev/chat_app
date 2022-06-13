import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:chat_app/models/users.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final users = [
    Users(online: true, email: 'saladavid0110@gmail.com', name: 'David', uid: '1'),
    Users(online: true, email: 'rominachavaldez@gmail.com', name: 'Romina', uid: '2'),
    Users(online: false, email: 'eltomas@gmail.com', name: 'Tomas', uid: '3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi nombre',
          style: TextStyle(color: Colors.blue),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {},
          color: Colors.blue,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Icon(Icons.check_circle, color: Colors.blue[400]),
            // child: Icon(Icons.check_circle, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _loadUsers,
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: Colors.blue,
          ),
          waterDropColor: Colors.purple,
        ),
        child: _ListViewUsers(users: users),
      ),
    );
  }

  _loadUsers() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}

class _ListViewUsers extends StatelessWidget {
  const _ListViewUsers({
    Key? key,
    required this.users,
  }) : super(key: key);

  final List<Users> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_, i) => _UserListTile(user: users[i]),
      separatorBuilder: (_, i) => const Divider(),
      itemCount: users.length,
    );
  }
}

class _UserListTile extends StatelessWidget {
  const _UserListTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Users user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        child: Text(user.name.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: user.online ? Colors.green[300] : Colors.red, borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
