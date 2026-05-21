class AppConstants {
  // Peanut Service
  static const String peanutBaseUrl = 'https://peanut.ifxdb.com';

  // Partner Service
  static const String partnerBaseUrl = 'https://client-api.contentdatapro.com';

  // SOAP Service
  static const String soapBaseUrl =
      'https://api-forexcopy.contentdatapro.com/Services/CabinetMicroService.svc';

  // Image CDN replacement
  static const String oldImageDomain = 'forex-images.instaforex.com';
  static const String newImageDomain = 'forex-images.ifxdb.com';

  // Currency pairs available
  static const List<String> currencyPairs = [
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'USDCHF',
    'USDCAD',
    'AUDUSD',
    'NZDUSD',
  ];

  // Storage keys
  static const String keyLogin = 'user_login';
  static const String keyPeanutToken = 'peanut_token';
  static const String keyPartnerToken = 'partner_token';
}
