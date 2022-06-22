import 'package:flutter/material.dart';
import 'package:vadasada/Models/route_argument.dart';
import 'package:vadasada/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/UI/LoginOrSignup/Signup.dart';
// import 'package:vadasada/UI/products/AddProduct.dart';
import 'package:vadasada/UI/bottomNavigationBar.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/Login':
        return MaterialPageRoute(builder: (_) => ChoseLogin());
      case '/Home':
        return MaterialPageRoute(builder: (_) => bottomNavigationBar());
      // case '/AddProduct':
      //   return MaterialPageRoute(builder: (_) => AddProduct());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => Signup());
      case '/LoginScreen':
        return MaterialPageRoute(builder: (_) => loginScreen());
      // case '/UploadProfilePic':
      //   return MaterialPageRoute(builder: (_) => UploadProfilePic());
      // case '/CompleteProfile':
      //   return MaterialPageRoute(builder: (_) => CompleteProfile());
      // case '/EligibilityForm':
      //   return MaterialPageRoute(builder: (_) => EligibilityForm());
      // case '/ReferenceForm':
      //   return MaterialPageRoute(builder: (_) => ReferenceForm());
      // case '/EmergencyForm':
      //   return MaterialPageRoute(builder: (_) => EmergencyForm());
      // case '/BankForm':
      //   return MaterialPageRoute(builder: (_) => BankForm());
      // case '/MedicalForm':
      //   return MaterialPageRoute(builder: (_) => MedicalForm());
      // case '/DocumentList':
      //   return MaterialPageRoute(builder: (_) => DocumentList());
      // case '/DocumentUpload':
      //   return MaterialPageRoute(
      //       builder: (_) =>
      //           DocumentUpload(routeArgument: args as RouteArgument));
      // case '/SubmitInfo':
      //   return MaterialPageRoute(builder: (_) => SumbitInfo());
      // case '/ProfileSummary':
      //   return MaterialPageRoute(builder: (_) => ProfileSummary());
      // case '/WageQueries':
      //   return MaterialPageRoute(builder: (_) => WageQuery());
      // case '/TimeSheet':
      //   return MaterialPageRoute(builder: (_) => TimeSheet());
      // case '/UploadTimesheet':
      //   return MaterialPageRoute(builder: (_) => UploadTimesheet());
      // case '/SubmitQueries':
      //   return MaterialPageRoute(builder: (_) => SubmitQuery());
      // case '/ChatWage':
      //   return MaterialPageRoute(
      //       builder: (_) => ChatWage(routeArgument: args as RouteArgument));
      // case '/ChatTimesheet':
      //   return MaterialPageRoute(
      //       builder: (_) =>
      //           ChatTimesheet(routeArgument: args as RouteArgument));
    }
  }
}
