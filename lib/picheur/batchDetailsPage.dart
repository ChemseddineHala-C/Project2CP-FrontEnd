// import 'package:flutter/material.dart';
//
// class BatchDetailspage extends StatefulWidget{
//   const BatchDetailspage ({super.key});
//   @override State<BatchDetailspage> createState() => _BatchDetailsState();
// }
//
// class _BatchDetailsState extends State<BatchDetailspage> {
//   final List<Map<String, String>> events = [
//     {
//       "title": "Approved by Market Manager",
//       "subtitle": "Oct 25, 09:15 AM • John Doe",
//     },
//     {
//       "title": "Pending Review",
//       "subtitle": "Oct 24, 06:45 AM • Quality Control",
//     },
//     {
//       "title": "Batch Created",
//       "subtitle": "Oct 24, 05:40 AM • Captain Sarah",
//     },
//   ];
//
//   bool _approved = false;
//   bool _pending = false;
//   bool _rejected = false;
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F7F9),
//       appBar: AppBar(
//         leading: IconButton(onPressed: (){},icon: Icon(Icons.arrow_back),color: Color(0xFF0F172A)),
//         title: Text("Batch Details", style: TextStyle(
//           color: Color(0xFF0F172A),
//           fontFamily: "Inter",
//           fontWeight: FontWeight.w700,
//           fontSize: 24,
//           letterSpacing: -0.6,
//         ),textAlign: TextAlign.center,),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body:SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.all(10),
//               width: 396,
//               height: 78,
//               decoration: BoxDecoration(
//                 color: Color(0xFFECFDF5),
//                 borderRadius: BorderRadiusGeometry.circular(13),
//                 border: BoxBorder.all(
//                   color: Color(0xFFD1FAE5),
//                   width: 1.5,
//                 )
//               ),
//               child: Row(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check_circle,color: Color(0xFF10B981),),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Text("CURRENT STATUS", style: TextStyle(
//                         color: Color(0xFF065F46),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w700,
//                         fontSize: 12,
//                         letterSpacing: 0.6
//                       ),),
//                       Text("APPROVED", style: TextStyle(
//                           color: Color(0xFF065F46),
//                           fontFamily: "Inter",
//                           fontWeight: FontWeight.w700,
//                           fontSize: 18,
//                       ),),
//
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               spacing: 5,
//               children: [
//                 Icon(Icons.sailing_outlined,color: Color(0xFF023E77)),
//                 Text("Catch Details",style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//               ],
//             ),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(15),
//               height: 86,
//               width: 396,
//               decoration: BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadiusGeometry.circular(13),
//                   border: BoxBorder.all(
//                     color: Color(0xFFE2E8F0),
//                     width: 0.5,
//                   )
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Fish name",style: TextStyle(
//                     color: Color(0xFF64748B),
//                     fontFamily: "Inter",
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),),
//                   Text("Sardine",style: TextStyle(
//                     color: Color(0xFF0F172A),
//                     fontFamily: "Inter",
//                     fontWeight: FontWeight.w700,
//                     fontSize: 24,
//                   ),),
//                 ],
//               ),
//             ),
//             SizedBox(height: 15),
//             Row(
//               spacing: 15,
//               children: [
//                 Expanded(child:Container(
//                   padding: EdgeInsets.all(15),
//                   height: 86,
//                   width: 396,
//                   decoration: BoxDecoration(
//                       color: Color(0xFFF8FAFC),
//                       borderRadius: BorderRadiusGeometry.circular(13),
//                       border: BoxBorder.all(
//                         color: Color(0xFFE2E8F0),
//                         width: 0.5,
//                       )
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Total Weight",style: TextStyle(
//                         color: Color(0xFF64748B),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                       ),),
//                       Text("45.5 kg",style: TextStyle(
//                         color: Color(0xFF0F172A),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                       ),),
//                     ],
//                   ),
//                 ),),
//                 Expanded(child: Container(
//                   padding: EdgeInsets.all(15),
//                   height: 86,
//                   width: 396,
//                   decoration: BoxDecoration(
//                       color: Color(0xFFF8FAFC),
//                       borderRadius: BorderRadiusGeometry.circular(13),
//                       border: BoxBorder.all(
//                         color: Color(0xFFE2E8F0),
//                         width: 0.5,
//                       )
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Total Value",style: TextStyle(
//                         color: Color(0xFF64748B),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                       ),),
//                       Text("1,137.50 DA",style: TextStyle(
//                         color: Color(0xFF023E77),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                       ),),
//                     ],
//                   ),
//                 ),)
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               spacing: 5,
//               children: [
//                 Icon(Icons.article_outlined,color: Color(0xFF023E77)),
//                 Text("Log Details",style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//               ],
//             ),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(13),
//               height: 172,
//               width: 389,
//               decoration: BoxDecoration(
//                 color: Color(0xFFFFFFFF),
//                 borderRadius: BorderRadiusGeometry.circular(13),
//                 border: BoxBorder.all(
//                   color: Color(0xFFE2E8F0),
//                   width: 0.5,
//                 )
//               ),
//               child: Column(
//                 children: [
//                   Expanded(child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         spacing: 10,
//                         children: [
//                           Icon(Icons.calendar_today_outlined,color: Color(0xFF94A3B8),),
//                           Text("Date & Time",style: TextStyle(
//                             color: Color(0xFF475569),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),)
//                         ],
//                       ),
//                       Text("Oct 24, 05:30 AM",style: TextStyle(
//                         color: Color(0xFF0F172A),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),),
//                     ],
//                   )),
//                   Divider(color: Color(0xFFF1F5F9), thickness: 1,),
//                   Expanded(child:Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         spacing: 10,
//                         children: [
//                           Icon(Icons.directions_boat_outlined,color: Color(0xFF94A3B8),),
//                           Text("Vessel Name ",style: TextStyle(
//                             color: Color(0xFF475569),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),)
//                         ],
//                       ),
//                       Text("Sea's King",style: TextStyle(
//                         color: Color(0xFF0F172A),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),),
//                     ],
//                   )),
//                   Divider(color: Color(0xFFF1F5F9), thickness: 1,),
//                   Expanded(child:Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         spacing: 10,
//                         children: [
//                           Icon(Icons.calendar_today_outlined,color: Color(0xFF94A3B8),),
//                           Text("Catch Method",style: TextStyle(
//                             color: Color(0xFF475569),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),)
//                         ],
//                       ),
//                       Text("Longline",style: TextStyle(
//                         color: Color(0xFF0F172A),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),),
//                     ],
//                   )),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               spacing: 5,
//               children: [
//                 Icon(Icons.location_on_outlined,color: Color(0xFF023E77)),
//                 Text("Catch Location",style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//               ],
//             ),
//             SizedBox(height: 20),
//             Container(
//               height: 192,
//               width: 394,
//               decoration: BoxDecoration(
//                 color: Color(0xFFE2E8F0),
//                 borderRadius: BorderRadiusGeometry.circular(13),
//                 border: BoxBorder.all(
//                   color: Color(0xFFE2E8F0),
//                   width: 0.5,
//                 )
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               spacing: 5,
//               children: [
//                 Icon(Icons.photo_library_outlined,color: Color(0xFF023E77)),
//                 Text("Catch Photos",style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//                 Spacer(),
//                 Text("View All (4)",style: TextStyle(
//                   color: Color(0xFF023E77),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),)
//               ],
//             ),
//             SizedBox(height: 20),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 spacing: 8,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadiusGeometry.circular(13),
//                     child: Image.asset("images/fish1.png",
//                       width: 139,
//                       height: 127,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   ClipRRect(
//                     borderRadius: BorderRadiusGeometry.circular(13),
//                     child: Image.asset("images/fish2.png",
//                       width: 139,
//                       height: 127,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   ClipRRect(
//                     borderRadius: BorderRadiusGeometry.circular(13),
//                     child: Image.asset("images/fish3.jpg",
//                       width: 139,
//                       height: 127,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               spacing: 5,
//               children: [
//                 Icon(Icons.history,color: Color(0xFF023E77)),
//                 Text("Status History",style: TextStyle(
//                   color: Color(0xFF0F172A),
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//               ],
//             ),
//             SizedBox(height: 5),
//             FixedTimeline.tileBuilder(
//               theme: TimelineThemeData(
//                 nodePosition:  0,
//                 connectorTheme: ConnectorThemeData(
//                   color: Colors.red,
//                   thickness: 2,
//                 ),
//               ),
//               builder: TimelineTileBuilder.connected(
//                 itemCount: events.length,
//                 itemExtent: 80,
//
//                 connectorBuilder: (context, index, type) => SolidLineConnector(
//                   color: Color(0xFF023E77),
//                   thickness: 2,
//                 ),
//                 indicatorBuilder: (context, index) => DotIndicator(
//                   color: index == 0? Color(0xFF023E77):Color(0xFFC4D3E0),
//                   size: 16,
//                   border: BoxBorder.all(
//                     color: Color(0xFFFFFFFF),
//                     width: 3.5,
//                   ),
//                 ),
//                 contentsBuilder: (context, index) => Padding(
//                     padding: EdgeInsetsGeometry.only(left: 8,top: 25),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${events[index]["title"]}",style: TextStyle(
//                         color: Color(0xFF0F172A),
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                         ),),
//                         SizedBox(height: 1,),
//                         Text("${events[index]["subtitle"]}",style: TextStyle(
//                             color: Color(0xFF64748B),
//                             fontFamily: "Inter",
//                             fontWeight: FontWeight.w400,
//                             fontSize: 14,
//                         )),
//                       ],
//                     ),
//                 ),
//               )
//             ),
//             SizedBox(height: 20),
//             Container(
//               height: 56,
//               width: 389,
//               child:ElevatedButton(onPressed: (){},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF023E77),
//                   foregroundColor: Color(0xFFFFFFFF),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadiusGeometry.circular(13),
//                   ),
//                   alignment: AlignmentGeometry.center,
//                 ),
//                 child:Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.save_alt_outlined,size: 20),
//                     SizedBox(width: 10,),
//                     Text("Download Receipt (PDF)", style: TextStyle(
//                       fontFamily: "Inter",
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),),
//
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//     );
//   }
// }


import 'package:flutter/material.dart';

import 'objects.dart';

class BatchDetailspage extends StatefulWidget {
  final BatchItem batch;
  const BatchDetailspage({super.key, required this.batch});
  @override
  State<BatchDetailspage> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetailspage> {
  final List<Map<String, String>> events = [
    // {
    //   "title": "Approved by Market Manager",
    //   "subtitle": "Oct 25, 09:15 AM • John Doe",
    // },
    // {
    //   "title": "Pending Review",
    //   "subtitle": "Oct 24, 06:45 AM • Quality Control",
    // },
    // {"title": "Batch Created", "subtitle": "Oct 24, 05:40 AM • Captain Sarah"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0F172A),
        ),
        title: const Text(
          "Batch Details",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusCard(widget.batch.status),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.sailing_outlined, color: Color(0xFF023E77)),
                const SizedBox(width: 5),
                const Text(
                  "Catch Summary",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              height: 86,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fish name",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.batch.fishName,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      decoration: widget.batch.status == "Rejected"
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Weight",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${widget.batch.quantity} kg", // Corrigé : quantity au lieu de weight
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Value",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${widget.batch.total} DA", // Corrigé : total au lieu de price
                          style: const TextStyle(
                            color: Color(0xFF023E77),
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.article_outlined, color: Color(0xFF023E77)),
                const SizedBox(width: 5),
                const Text(
                  "Log Details",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(13),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              ),
              child: Column(
                children: [
                  _buildLogTile(
                    Icons.calendar_today_outlined,
                    "Date & Time",
                    widget.batch.date,
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  _buildLogTile(
                    Icons.directions_boat_outlined,
                    "Vessel Name",
                    "Sea's King",
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  _buildLogTile(
                    Icons.anchor_outlined,
                    "Catch Method",
                    widget.batch.catchMethod ?? "Longline",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF023E77),
                ),
                const SizedBox(width: 5),
                const Text(
                  "Catch Location",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 192,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Image.asset(
                        "images/mapLocation.jpg",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          // decoration: BoxDecoration(

                          //   borderRadius: BorderRadius.circular(6),
                          // ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "COORDINATES",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "${widget.batch.latitude?.toStringAsFixed(4) ?? 'N/A'}° N, "
                                    "${widget.batch.longitude?.toStringAsFixed(4) ?? 'N/A'}° W",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF023E77),
                ),
                const SizedBox(width: 5),
                const Text(
                  "Catch Photos",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  "View All (${widget.batch.pictures.length})",
                  style: const TextStyle(
                    color: Color(0xFF023E77),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.batch.pictures
                    .map(
                      (path) => Row(
                    children: [
                      _buildFishImage(path),
                      if (widget.batch.pictures.last != path)
                        const SizedBox(width: 10),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF023E77)),
                const SizedBox(width: 5),
                const Text(
                  "Status History",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Version manuelle de la timeline (pour éviter l'erreur de package)
            Column(
              children: List.generate(
                events.length,
                    (index) => _buildTimelineTile(index),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF023E77),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt_outlined, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Download Receipt (PDF)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.asset(path, width: 139, height: 127, fit: BoxFit.cover),
    );
  }

  Widget _buildTimelineTile(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: index == 0
                    ? const Color(0xFF023E77)
                    : const Color(0xFFC4D3E0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            if (index != events.length - 1)
              Container(width: 2, height: 50, color: const Color(0xFF023E77)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                events[index]["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                events[index]["subtitle"]!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _statusCard(String status) {
  Color bgColor;
  Color textColor;
  Color border;
  IconData icon;

  switch (status) {
    case "Approved":
      bgColor = Color(0xFFECFDF5);
      textColor = Color(0xFF065F46);
      icon = Icons.check_circle_outline;
      border = Color(0xFFD1FAE5);
      break;
    case "Rejected":
      bgColor = Color(0xFFFFEBEC);
      textColor = Color(0xFFBD3456);
      icon = Icons.cancel_outlined;
      border = Color(0x99FAD6D1);
      break;
    case "Pending":
      bgColor = Color(0xFFFEF3C7);
      textColor = Color(0xFFB45309);
      icon = Icons.access_time_outlined;
      border = Color(0xFFF0E6BC);
      break;
    default:
      bgColor = Color(0xFFE3E3E3);
      textColor = Color(0xFF475569);
      icon = Icons.history;
      border = Color(0xFFE1E1E1);
  }

  return Container(
    padding: const EdgeInsets.all(10),
    width: double.infinity,
    height: 78,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: border, width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CURRENT STATUS",
              style: TextStyle(
                color: textColor,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: textColor,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}