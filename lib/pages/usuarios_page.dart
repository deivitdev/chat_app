import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:chat_app/models/usuario.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final users = [
    Usuario(online: true, email: 'saladavid0110@gmail.com', nombre: 'David', uid: '1'),
    Usuario(online: true, email: 'rominachavaldez@gmail.com', nombre: 'Romina', uid: '2'),
    Usuario(online: false, email: 'eltomas@gmail.com', nombre: 'Tomas', uid: '3'),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario?.nombre ?? 'Sin Nombre',
          style: TextStyle(color: Colors.blue),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            //TODO: desconectarnos del socket server

            AuthService.deleteToken();
            Navigator.pushReplacementNamed(context, 'login');
          },
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
        child: _ListViewUsers(usuarios: users),
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
    required this.usuarios,
  }) : super(key: key);

  final List<Usuario> usuarios;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_, i) => _UserListTile(user: usuarios[i]),
      separatorBuilder: (_, i) => const Divider(),
      itemCount: usuarios.length,
    );
  }
}

class _UserListTile extends StatelessWidget {
  const _UserListTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Usuario user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.nombre),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        child: Text(user.nombre.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: user.online ? Colors.green[300] : Colors.red, borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
