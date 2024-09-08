import 'dart:io';
import 'dart:math';

Map<String, Map<String, dynamic>> Committee= {};

String id_generator({int len = 4}) {
  var random = Random();
  const dict = '1234567890';
  return List.generate(len, (index) => dict[random.nextInt(dict.length)]).join();
}

String password_generator({int len = 4}) {
  var random = Random();
  const dict = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => dict[random.nextInt(dict.length)]).join();
}



void createCommittee(var name, var price, var requiredMembers) {
  String committeeID = id_generator(); 
  String password = password_generator(); 
    
  DateTime now = DateTime.now();
  DateTime scheduleDate = DateTime(now.year, now.month, 17);
  
  Committee[committeeID] = {
    'name': name,
    'price': price,
    'requiredMembers': requiredMembers,
    'members': [],
    'password': password,
    'schedule': scheduleDate,
  };

  print('Committee $name created with ID: $committeeID and password: $password');
}

void add_member(var committeeID,var name,var phoneNumber,var email){
  if(Committee.containsKey(committeeID)){
    Committee[committeeID]?['members'].add({'name': name, 'phone': phoneNumber, 'email': email});
    print('Member $name added to committee $committeeID');
  }
  else {
    print('Committee not found.');
  }
}

void remove_member(String committeeID, var name) {
  if (Committee.containsKey(committeeID)) {
    var members = Committee[committeeID]?['members'];
    members.removeWhere((member) => member['name'] == name);
    print('Member $name has been removed from committee: $committeeID');
  } else {
    print('Committee not found.');
  }
}


void update_member(String committeeID,var name,var phoneNumber,var email){
  if (Committee.containsKey(committeeID)) {
    var members = Committee[committeeID]?['members'];
    for (var member in members) {
      if (member['name'] == name) {
        member['phone'] = phoneNumber;
        member['email'] = email;
        print('Details for $name updated.');
      }
    }
  } else {
    print('Committee not found.');
  }
}

void listMembers(var committeeID) {
  if (Committee.containsKey(committeeID)) {
    var members = Committee[committeeID]?['members'];
    for (var member in members) {
      print('Member Name: ${member['name']}, Phone: ${member['phone']}, Email: ${member['email']}');
    }
  } else {
    print('Committee not found.');
  }
}

void pick_member(var committeeID){
  if(Committee.containsKey(committeeID)){
    var all_members = Committee[committeeID]?['members'];
      if (all_members != null && all_members.isNotEmpty){
        var random_member = all_members[Random().nextInt(all_members.length)];
        print("Selected member is $random_member from committee $committeeID. ");
      }
      else{
        print("No members found in committe $committeeID.");
      }
      }
  else{
    print("No committee found with ID: $committeeID.");
  }
}


bool committe_login(String committeeID, String password) {
  if (Committee.containsKey(committeeID)) {
    return Committee[committeeID]?['password'] == password;
  }
  return false;
}


String userLogin() {
  print("Enter Committee ID: ");
  String? committeeID = stdin.readLineSync();
  
  if(Committee.containsKey(committeeID)){

  print("Enter Password: ");
  String? password = stdin.readLineSync();
  
  if (committeeID != null && password != null && committe_login(committeeID, password)) {
    print("Login successful.");
    return committeeID;
  } else {
    print("Invalid ID or Password.");
    return "0000";
  }
  }
  else{
    print("No committee found with given ID: $committeeID. ");
    return "0000";
  }
}


void viewCommitteeInformation() {
  print('1. View Committee Schedule');
  print('2. View Committee Statistics');
  print('3. Back');
  
  String? choice = stdin.readLineSync();
  
  switch (choice) {
    case '1':
      viewCommitteeSchedule();
      break;
    case '2':
      viewCommitteeStatistics();
      break;
    case '3':
      return;
    default:
      print('Invalid choice.');
  }
}

void viewCommitteeSchedule() {
  print('Scheduled Committees:');
  for (var committeeID in Committee.keys) {
    var schedule = Committee[committeeID]?['schedule'];
    print('Committee ID: $committeeID, Scheduled Date: $schedule');
  }
}

void viewCommitteeStatistics() {
  print('Committee Statistics:');
  for (var committeeID in Committee.keys) {
    var committee = Committee[committeeID];
    var members = committee?['members'];
    
    int totalMembers;
    var requiredMembers = committee?['requiredMembers'];

    if (requiredMembers is String) {

      totalMembers = int.tryParse(requiredMembers) ?? 0;
    } else if (requiredMembers is int) {

      totalMembers = requiredMembers;
    } else {

      totalMembers = 0;
    }

    var currentMembers = members.length;
    var remainingMembers = totalMembers - currentMembers;

    print('Committee ID: $committeeID');
    print('Total Members Required: $totalMembers');
    print('Current Members: $currentMembers');
    print('Remaining Members: $remainingMembers');
    print('');
  }
}


void list_all_committees() {
  if (Committee.isEmpty) {
    print("No committees available.");
    return;
  }

  print("List of all Committee IDs:");
  for (var committeeID in Committee.keys) {
    print(committeeID);
  }
}


void main(){


  
  while (true) {
    print('1. Create Committee');
    print('2. Add Member');
    print('3. Remove Member');
    print('4. Update Member Details');
    print('5. List Members');
    print('6. Pick a Member');
    print('7. View Committee Information');
    print('8. List all Committees');

    print('9. Exit');
    
    var choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        print("Enter Committee Name: ");
        var name = stdin.readLineSync();
        
        print("Enter Committee Price: ");
        var price = stdin.readLineSync();
        
        print("Enter Required Number of Members: ");
        var requiredMembers = stdin.readLineSync();
        
        createCommittee(name, price, requiredMembers);
        break;
      
      case '2':
        var committeeID = userLogin();

        if(committeeID=="0000"){
          break;
        }
        
        print("Enter Member Name: ");
        var name = stdin.readLineSync();
        
        print("Enter Member Phone Number: ");
        var phoneNumber = stdin.readLineSync();
        
        print("Enter Member Email: ");
        var email = stdin.readLineSync();
        
        add_member(committeeID, name, phoneNumber, email);
        break;
      
      case '3':
        var committeeID = userLogin();
        if(committeeID=="0000"){
          break;
        }
        print("Enter Name: ");
        var name = stdin.readLineSync();
        remove_member(committeeID,name);
        break;
      
      case '4':
        var committeeID = userLogin();
        if(committeeID=="0000"){
          break;
        }
        
        print("Enter Member Name: ");
        var name = stdin.readLineSync();
        
        print("Enter Member Phone Number: ");
        var phoneNumber = stdin.readLineSync();
        
        print("Enter Member Email: ");
        var email = stdin.readLineSync();
        
        update_member(committeeID, name, phoneNumber, email);
        break;

      case '5':
        var committeeID = userLogin();
        if(committeeID=="0000"){
          break;
        }
        listMembers(committeeID);
        break;
      
      case '6':
        var committeeID = userLogin();
        if(committeeID=="0000"){
          break;
        }
        pick_member(committeeID);
        break;
      
      case '7':
        viewCommitteeInformation();
        break;
      
      case '8':
        list_all_committees();
        break;

      case '9':
        return;
      
      default:
        print('Invalid choice.');
    }
  }
}



