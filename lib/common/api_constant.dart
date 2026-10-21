class APIConstant {
  // Production URL:
  // static const baseUrl = "https://shyamtilesadmin.on-forge.com";

  // Local MAMP URL (iOS Simulator / Mac):
  static const baseUrl = "http://127.0.0.1:8888/shyamtiles_admin_panel";

  static const userLogin = "$baseUrl/index.php/apis/Login";

  static const appBanners = "$baseUrl/index.php/apis/BannerImages";
  static const appGallery = "$baseUrl/index.php/apis/GalleryImages";

  static const appContact = "$baseUrl/index.php/apis/ContactData";
  static const appProducts = "$baseUrl/index.php/apis/getProducts";

  static const addWishList = "${baseUrl}/index.php/apis/addWishList";
  static const removeFromWishList =
      "${baseUrl}/index.php/apis/removeFromWishList";
  static const sendEnquiry = "${baseUrl}/index.php/apis/sendEnquiry";
  static const sendBookings = "${baseUrl}/apis/sendBookings";
  static const getWishList = "${baseUrl}/index.php/apis/getWishList";

  static const productCategories = "$baseUrl/index.php/apis/productCategories";

  // Sign-up flow
  static const appSettings = "$baseUrl/index.php/apis/AppSettings";
  static const registerUser = "$baseUrl/index.php/apis/RegisterUser";
}

