import 'dart:io';

import 'package:drivers_app/authentication/car_info_screen.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignUpScreen extends StatefulWidget
{
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}




class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  File? _selectedImage;



  validateForm()
  {
    if (nameTextEditingController.text.length < 3)
      {
        Fluttertoast.showToast(msg: "Nombre debe tener al menos 3 caracteres.");
      }
    else if(!emailTextEditingController.text.contains("@"))
      {
        Fluttertoast.showToast(msg: "Proporcione un email correcto.");
      }
    else if(phoneTextEditingController.text.isEmpty)
      {
        Fluttertoast.showToast(msg: "Numero de telefono es obligatorio");
      }
    else if(passwordTextEditingController.text.length < 6)
    {
      Fluttertoast.showToast(msg: "La contraseña debe tener al menos 6 caracteres");
    }
    else if(_selectedImage == null)
      {
        Fluttertoast.showToast(msg: "Tienes que tomar una foto");
      }
    else
    {
      saveDriverInfoNow();
    }
  }

  saveDriverInfoNow() async
  {
    showDialog        (
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return ProgressDialog(message: "Procesando por favor espere...",);
        }
    );

    final User? firebaseUser = (
        await  fAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error " + msg.TroString());
        })
    ).user;

    if(firebaseUser != null)
      {
        String imagePath = _selectedImage?.path ?? ''; // Get the path of the selected image, or an empty string if no image is selected
        String imageName = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique name for the image

        firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('driver_photos')
            .child(imageName);

        // Upload the image file to Firebase Storage
        firebase_storage.UploadTask uploadTask = storageReference.putFile(File(imagePath));

        // Get the download URL of the uploaded image
        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
        String photoUrl = await taskSnapshot.ref.getDownloadURL();
        Map driverMap =
            {
              "id": firebaseUser.uid,
              "name": nameTextEditingController.text.trim(),
              "email": emailTextEditingController.text.trim(),
              "phone": phoneTextEditingController.text.trim(),
              "photo": photoUrl,
            };

        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
        driversRef.child(firebaseUser.uid).set(driverMap);

        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: "Cuenta fue creada");
        Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen()));
      }
    else
      {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Cuenta no fue creada");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 30,),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Image.asset("images/logo1.png"),
              ),

              const SizedBox(height: 30,),

              const Text(
                "Registrate como conductor",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold ,
                ),
              ),

              TextField(
                controller: nameTextEditingController,
                keyboardType: TextInputType.name,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  hintText: "Nombre",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Telefono",
                  hintText: "Telefono",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  hintText: "Contraseña",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              // tomar foto con la camara

              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                  },
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent
                ),
                child: const Text(
                  'Tomar Foto',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 75, color: Colors.grey),
              ),

      //acaba tomar foto con la camara


      const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  validateForm();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent
                ),
                child: const Text(
                  "Crear Cuenta",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              TextButton(
                child: const Text(
                  "Ya tienes una cuenta? Click aqui",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

