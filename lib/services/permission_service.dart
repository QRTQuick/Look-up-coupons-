import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestAll() async {
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.storage.request();
    await Permission.notification.request();
  }
}
