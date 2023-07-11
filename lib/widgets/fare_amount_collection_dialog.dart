import 'dart:io';

import 'package:drivers_app/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() =>
      _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  File? _selectedImage;

  Future<void> saveRidePhoto() async {
    if (_selectedImage == null) {
      return;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('driver_item_photos')
        .child(imageName);

    // Upload the image file to Firebase Storage
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_selectedImage!);

    // Wait for the upload task to complete
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String photoUrl = await taskSnapshot.ref.getDownloadURL();

    // TODO: Perform any necessary operations with the photo URL
  }



  void confirmPhoto(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(currentFirebaseUser!.uid)
        .child("photoMatch")
        .once()
        .then((snapshot) {
      String? photoMatch = snapshot.snapshot.value?.toString();

      if (photoMatch == "false") {
        Fluttertoast.showToast(msg: "Aun no esta confirmada la foto");
      } else {
        Fluttertoast.showToast(msg: "Se confirmo la foto");
        Future.delayed(const Duration(milliseconds: 5000), () {
          SystemNavigator.pop();
        });
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.grey,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            Text(
              "Cobro justo de delivery " + "(" + driverVehicleType!.toUpperCase() + ")",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20,),
            const Divider(
              thickness: 4,
              color: Colors.grey,
            ),
            const SizedBox(height: 16,),
            Text(
              widget.totalFareAmount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Este es el total del delivery, Cobrele al cliente",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
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
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () async {
                await saveRidePhoto();
                Fluttertoast.showToast(msg: "Se subio la foto");
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreenAccent,
              ),
              child: const Text(
                'Subir Foto',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                onPressed: ()
                {
                    confirmPhoto(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cobrar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Bs  " + widget.totalFareAmount!.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4,),
          ],
        ),
      ),
    );
  }
}
