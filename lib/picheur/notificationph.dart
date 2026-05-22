import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().noti();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return dateStr;
    }
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
            final List<dynamic> notifications =
                state.user["notifications"] ?? [];

            return RefreshIndicator(
              onRefresh: () async => context.read<AuthCubit>().noti(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mark all as read
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Mark all as read",
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (notifications.isEmpty)
                      _buildEmptyState()
                    else
                      ...notifications.map((notif) =>
                          _buildNotifCard(notif, isDark)).toList(),

                    const SizedBox(height: 20),
                    _buildEmptyState(),
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

  Widget _buildNotifCard(Map<String, dynamic> notif, bool isDark) {
    final bool isRead = notif["is_read"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead
            ? (isDark ? Colors.white10 : Colors.white)
            : (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isRead ? Colors.transparent : Colors.blue,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif["title"] ?? "N/A",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif["message"] ?? "N/A",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Temps + point non lu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(notif["created_at"] ?? ""),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              if (!isRead)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.blue),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.notifications_off_outlined, color: Colors.grey[400], size: 60),
          const SizedBox(height: 8),
          Text(
            "No more recent notifications",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../signin/cubit/authcubit.dart';
// import '../signin/cubit/authstate.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
//
//
// final FlutterSecureStorage storage = const FlutterSecureStorage();
//
// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});
//
//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }
//
// class _NotificationPageState extends State<NotificationPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<AuthCubit>().noti();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           "Notification",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: BlocBuilder<AuthCubit, AuthState>(
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is ProfileLoaded) {
//             final user = state.user;
//
//             return RefreshIndicator(
//               onRefresh: () async {
//                 await context.read<AuthCubit>().noti();
//               },
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Mark all as read",
//                           style: TextStyle(color: Colors.blue[900]),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//
//                           _filterButton("All"),
//                           _filterButton("Batches"),
//                           _filterButton("Safety"),
//
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20,),
//                     _buildNotifieCard(user, isDark),
//                     const SizedBox(height: 15,),
//                     _buildnotifieicon(isDark)
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           if (state is ProfileError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(state.message),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context.read<AuthCubit>().noti(),
//                     child: const Text("Retry"),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return const Center(child: Text("No Notification Data Available"));
//         },
//       ),
//     );
//   }
//   Widget _filterButton(String text) {
//     return ElevatedButton(
//       onPressed: () {},
//       child: Text(text),
//     );
//   }
//   Widget _buildNotifieCard(Map<String, dynamic> user, bool isDark) {
//     return
//       Card(
//           elevation: 0,
//           margin: EdgeInsets.symmetric(horizontal: 5),
//           color: Theme.of(context).cardColor,
//           child: Row(
//               children: [
//                 Expanded(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ListTile(
//                             title: Text("${user["title"] ?? "N/A"}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
//                             subtitle: Text("${user["message"] ?? "N/A"}",style: TextStyle(color: Colors.grey),),
//                             trailing: Text("${user["created_at"] ?? "N/A"}",style:TextStyle(color: Colors.grey,fontSize: 20),),
//
//                           )
//                         ]
//                     )
//                 )
//               ]
//           )
//       );
//   }
//   Widget _buildnotifieicon( bool isDark) {
//     return Column(
//       children: [
//         Icon(Icons.notifications,color: Colors.grey,size: 60,),
//         Text("No more recent notifications",style: TextStyle(color: Colors.grey),)
//       ],
//     );
//   }
// }
