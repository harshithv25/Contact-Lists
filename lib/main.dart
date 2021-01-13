import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  List<Contact> filterdContacts = [];
  final formKey = GlobalKey<FormState>();
  TextEditingController searchedContact = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchedContact.addListener(() {
      filterContacts();
    });
  }

  getAllContacts() async {
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = _contacts;
    });
  }

  flattenPhnNo(String phone) {
    return phone.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == '+' ? "+" : "";
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchedContact.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String term = searchedContact.text.toLowerCase();
        String searchTermFlattened = flattenPhnNo(term);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(term);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlattened.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((element) {
          String flatten = flattenPhnNo(element.value);
          return flatten.contains(searchTermFlattened);
        }, orElse: () => null);

        return phone != null;
      });

      setState(() {
        filterdContacts = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchedContact.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Contacts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(220, 220, 220, 1),
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Container(
                  child: Expanded(
                    child: TextField(
                      controller: searchedContact,
                      decoration: InputDecoration(
                        hintText: 'Search Contacts',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: isSearching == true
                  ? filterdContacts.length
                  : contacts.length,
              itemBuilder: (context, index) {
                Contact contact = isSearching == true
                    ? filterdContacts[index]
                    : contacts[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 5, top: 5),
                  child: ListTile(
                    onTap: () {},
                    title: Text(contact.displayName),
                    subtitle: Text(contact?.phones?.elementAt(0)?.value),
                    leading: contact.avatar.length > 0 && contact.avatar != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(contact.avatar),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              contact.initials(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
