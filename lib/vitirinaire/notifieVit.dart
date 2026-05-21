import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



final FlutterSecureStorage storage = const FlutterSecureStorage();

class NotificationVitPage extends StatefulWidget {
  const NotificationVitPage({super.key});

  @override
  State<NotificationVitPage> createState() => _NotificationVitPageState();
}

class _NotificationVitPageState extends State<NotificationVitPage> {

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().noti();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.user;

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<AuthCubit>().noti();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Mark all as read",
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          _filterButton("All"),
                          _filterButton("Batches"),
                          _filterButton("Safety"),

                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    _buildNotifieCard(user, isDark),
                    const SizedBox(height: 15,),
                    _buildnotifieicon(isDark)
                  ],
                ),
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().noti(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("No Notification Data Available"));
        },
      ),
    );
  }
  Widget _filterButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(text),
    );
  }
  Widget _buildNotifieCard(Map<String, dynamic> user, bool isDark) {
    return
      Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(horizontal: 5),
          color: Theme.of(context).cardColor,
          child: Row(
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text("${user["title"] ?? "N/A"}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                            subtitle: Text("${user["message"] ?? "N/A"}",style: TextStyle(color: Colors.grey),),
                            trailing: Text("${user["created_at"] ?? "N/A"}",style:TextStyle(color: Colors.grey,fontSize: 20),),

                          )
                        ]
                    )
                )
              ]
          )
      );
  }
  Widget _buildnotifieicon( bool isDark) {
    return Column(
      children: [
        Icon(Icons.notifications,color: Colors.grey,size: 60,),
        Text("No more recent notifications",style: TextStyle(color: Colors.grey),)
      ],
    );
  }
}
