import 'package:fishapp/signin/signup/secondpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fishapp/signin/login.dart';

class Firstpage extends StatefulWidget{
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}
class _FirstpageState extends State<Firstpage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB8D8E8),
                    Color(0xFF5BA3C4),
                    Color(0xFF3D8BAD),
                  ],
                ),
              ),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image.asset(
                  'images/Bahr.png',
                  width: 280,
                  // ↑ ajuste selon la taille souhaitée
                  fit: BoxFit.contain,
                  // ↑ garde les proportions du logo
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), //  coins arrondis
              ),
              width: double.infinity,
              height: 300,
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Center(
                      child: Text("Welcom to Let's Fishing",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  SizedBox(height: 40,),
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 50,
                      child: MaterialButton(
                        color: const Color(0xFF013D73),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Secondpage()),
                          );
                        },
                        child: const Text(
                          "Create an account",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  Row(
                    children: [
                      Container(padding: EdgeInsets.only(left: 50),child: Text("Already have an account?"),),
                      TextButton(onPressed: (){Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );}, child: Text("Log in",style: TextStyle(color:Colors.blue,fontWeight: FontWeight.bold),)),
                    ],
                  ),
                ],
              ),
            ),

          ],
        )

    );
  }
}