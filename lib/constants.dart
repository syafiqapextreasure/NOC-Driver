import 'package:nocdriver/model/TaxModel.dart';
import 'package:nocdriver/model/mail_setting.dart';
import 'package:location/location.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'model/CurrencyModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
LocationData? locationDataFinal;

const COLOR_ACCENT = 0xFFD4D847;
const COLOR_PRIMARY_DARK = 0xFF2c7305;
var COLOR_PRIMARY = 0xFFFFFC05;
const DARK_COLOR = 0xff000000;
const COLOR_ACCENt1 = 0xFF94D5BE;
const DARK_CARD_BG_COLOR = 0xff000000; // 0xFF5EA23A;

var WHITE = 0xFFFFFFFF;
// 0xFF5EA23A;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const USERS = 'users';
const CARMAKES = 'car_make';
const VEHICLETYPE = 'vehicle_type';
const RENTALVEHICLETYPE = 'rental_vehicle_type';
const CARMODEL = 'car_model';
const RIDESORDER = "rides";
const PARCELORDER = "parcel_orders";
const RENTALORDER = "rental_orders";
const SECTION = 'sections';

String appVersion = '';

const STORAGE_ROOT = 'emart';
const REPORTS = 'reports';
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const Setting = 'settings';
const CONTACT_US = 'ContactUs';
const ORDERS = 'vendor_orders';
const OrderTransaction = "order_transactions";
const driverPayouts = "driver_payouts";
const Order_Rating = 'items_review';
const Wallet = "wallet";
const REFERRAL = 'referral';
const dynamicNotification = 'dynamic_notification';
const emailTemplates = 'email_templates';

const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const GlobalURL = "https://nocglobal.my/";

String SERVER_KEY =
    'AAAAYKYVaUA:APA91bGOSiK4mbR5tYbpYlHuS0iElkV5UE3T1QaUzJQbzzX39h87rD9blQIjl9ER0ksBScmIomRO96YtS4ZVjjYDbH3jcFb_a00WzA3OWnKVKiSsuSle24bWHuSZCsQZQjKNDXRZ3WdS';
String GOOGLE_API_KEY = 'AIzaSyAvNwZ_RUaMuDHblwRJBi1QYs8oZQK8xOs';

String placeholderImage =
    'https://firebasestorage.googleapis.com/v0/b/emart-8d99f.appspot.com/o/images%2Fplace_holder%20(2).png?alt=media&token=c2eb35a9-ddf2-4b66-9cc6-d7d82e48d97b';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_ACCEPTED = 'Driver Accepted';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDER_REACHED_DESTINATION = 'Reached Destination';

const driverCompleted = "driver_completed";
const driverAccepted = "driver_accepted";
const cabAccepted = "cab_accepted";
const cabCompleted = "cab_completed";
const parcelAccepted = "parcel_accepted";
const parcelCompleted = "parcel_completed";
const parcelRejected = "parcel_rejected";
const rentalRejected = "rental_rejected";
const rentalAccepted = "rental_accepted";
const startRide = "start_ride";
const rentalCompleted = "rental_completed";

const walletTopup = "wallet_topup";
const newVendorSignup = "new_vendor_signup";
const payoutRequestStatus = "payout_request_status";
const payoutRequest = "payout_request";
const newOrderPlaced = "new_order_placed";
const newCarBook = "new_car_book";

const USER_ROLE_DRIVER = 'driver';

const DEFAULT_CAR_IMAGE =
    'https://firebasestorage.googleapis.com/v0/b/emart-8d99f.appspot.com/o/images%2Fcar_default_image.png?alt=media&token=ba12a79d-d876-4b1c-87ed-2b06cd5b50f0';

const Currency = 'currencies';

int driverOrderAcceptRejectDuration = 60;
bool enableOTPParcelReceive = false;
bool enableOTPTripStart = false;

CurrencyModel? currencyData;
String currentCabOrderID = "";

String minimumAmountToWithdrawal = "0.0";
String minimumDepositToRideAccept = "0.0";

String amountShow({required String? amount}) {
  if (currencyData?.symbolatright == true) {
    return "${double.parse(amount.toString()).toStringAsFixed(currencyData!.decimal)} ${currencyData!.symbol.toString()}";
  } else {
    return "${currencyData?.symbol ?? "\$"} ${double.parse(amount.toString()).toStringAsFixed(currencyData?.decimal ?? 0)}";
  }
}

double calculateTax({String? amount, TaxModel? taxModel}) {
  double taxAmount = 0.0;
  if (taxModel != null && taxModel.enable == true) {
    if (taxModel.type == "fix") {
      taxAmount = double.parse(taxModel.tax.toString());
    } else {
      taxAmount = (double.parse(amount.toString()) *
              double.parse(taxModel.tax!.toString())) /
          100;
    }
  }
  return taxAmount;
}

MailSettings? mailSettings;

final smtpServer = SmtpServer(mailSettings!.host.toString(),
    username: mailSettings!.userName.toString(),
    password: mailSettings!.password.toString(),
    port: 465,
    ignoreBadCertificate: false,
    ssl: true,
    allowInsecure: true);

sendMail(
    {String? subject,
    String? body,
    bool? isAdmin = false,
    List<dynamic>? recipients}) async {
  // Create our message.
  if (isAdmin == true) {
    recipients!.add(mailSettings!.userName.toString());
  }
  final message = Message()
    ..from = Address(
        mailSettings!.userName.toString(), mailSettings!.fromName.toString())
    ..recipients = recipients!
    ..subject = subject
    ..text = body
    ..html = body;

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print(e);
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
