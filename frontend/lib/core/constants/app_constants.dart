class AppConstants {
  static const String appName = 'FirstHome Nigeria';
  static const String appTagline = 'Find trusted professionals for your home.';
  static const String appSubtitle =
      'From everyday repairs to home improvements, connect with skilled service providers in your area.';

  // Default API Base URL for backend.
  // Can be overridden at build/deploy time via: --dart-define=API_BASE_URL=https://your-api.com/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5277/api',
  );

  static const List<String> nigerianStates = [
    'Lagos',
    'Abuja (FCT)',
    'Rivers',
    'Oyo',
    'Kano',
    'Enugu',
    'Akwa Ibom',
    'Delta',
    'Kaduna',
    'Ogun',
  ];

  static const Map<String, List<String>> stateCities = {
    'Lagos': ['Ikeja', 'Lekki', 'Yaba', 'Victoria Island', 'Surulere', 'Maryland', 'Ikoyi'],
    'Abuja (FCT)': ['Wuse', 'Garki', 'Maitama', 'Asokoro', 'Gwarinpa', 'Jabi'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme', 'Bonny'],
    'Oyo': ['Ibadan', 'Ogbomosho', 'Oyo'],
    'Kano': ['Nasarawa', 'Fagge', 'Dala', 'Kano Municipal'],
    'Enugu': ['Independence Layout', 'GRA', 'New Haven', 'Trans-Ekulu'],
    'Akwa Ibom': ['Uyo', 'Eket', 'Ikot Ekpene'],
    'Delta': ['Asaba', 'Warri', 'Sapele'],
    'Kaduna': ['Kaduna North', 'Kaduna South', 'Zaria'],
    'Ogun': ['Abeokuta', 'Sagamu', 'Ijebu Ode', 'Ota'],
  };

  static const List<String> enquiryTypes = [
    'Service request',
    'Housing enquiry',
  ];

  static const List<String> contactMethods = [
    'Phone',
    'Email',
    'WhatsApp',
  ];

  static const List<String> leadStatuses = [
    'New',
    'Contacted',
    'Qualified',
    'Closed',
  ];
}
