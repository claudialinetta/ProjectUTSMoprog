import '../models/contact_model.dart';

class ContactService {
  Future<List<ContactModel>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ContactModel(
        id: "1",
        name: "Bagas Dribble",
        phoneNumber: "+62 812-3456-7890",
        tag: "Trusted",
        reportCount: 0,
        avatarInitial: "BS",
      ),
      ContactModel(
        id: "2",
        name: "Unknown Caller",
        phoneNumber: "+62 812-1111-1111",
        tag: "Spam Likely",
        reportCount: 143,
        avatarInitial: "?",
      ),
      ContactModel(
        id: "3",
        name: "Fufufafa",
        phoneNumber: "+62 821-2121-2121",
        tag: "Unknown",
        reportCount: 19,
        avatarInitial: "F",
      ),
      ContactModel(
        id: "4",
        name: "Delivery Courier",
        phoneNumber: "+62 899-2222-3333",
        tag: "Trusted",
        reportCount: 4,
        avatarInitial: "DC",
      ),
    ];
  }
}
