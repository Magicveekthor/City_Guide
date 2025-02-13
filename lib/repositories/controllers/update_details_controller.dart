import 'package:cityguide/repositories/controllers/user_controller.dart';
import 'package:cityguide/repositories/repos/user_repository.dart';
import 'package:cityguide/screens/mainscreens/profile/profilescreen.dart';
import 'package:cityguide/utils/constants/image_strings.dart';
import 'package:cityguide/utils/helpers/network_manager.dart';
import 'package:cityguide/utils/popups/full_screen_loader.dart';
import 'package:cityguide/utils/popups/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateDetailsController extends GetxController {
  static UpdateDetailsController get instance => Get.find();

  ///variables
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserDetailsFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeDetails();
    super.onInit();
  }


  /// Fetch user record
  Future<void> initializeDetails() async {
    firstName.text = userController.userInfo.value.firstName;
    lastName.text = userController.userInfo.value.lastName;
    phoneNumber.text = userController.userInfo.value.phoneNumber;
  }

  /// Save user Record from any Registration Provider
  Future<void> updateUserDetails() async {
    try {
      ///start loading
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information ...', TImages.decorAnimation);

      ///check internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        //remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }

      ///Form validation
      if (!updateUserDetailsFormKey.currentState!.validate()) {
        //remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }


      /// Update user's infomation in the Firebase
      Map<String, dynamic> details = {'FirstName': firstName.text.trim(), 'LastName': lastName.text.trim(), 'PhoneNumber': phoneNumber.text.trim()};
      await userRepository.updateSingleField(details);


      ///update the Rx User value
      userController.userInfo.value.firstName = firstName.text.trim();
      userController.userInfo.value.lastName = lastName.text.trim();
      userController.userInfo.value.phoneNumber = phoneNumber.text.trim();

      //remove Loader
      TFullScreenLoader.stopLoading();

      ///show success Message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your Account Details has been updated.');

      ///Move to verify Email screen
      Get.to(() => const profileScreen());
    } catch (e) {
//remove Loader
      TFullScreenLoader.stopLoading();

      ///show generic error to user
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
  }
