

import Foundation
import UIKit
import MFSideMenu

//MARK:- Common Keys

let deviceTokenn = "123456"
let TIMEOUT_INTERVAL = 30.0
let OS_PLATEFORM = "ios"
let LOCATION_UPDATED = "LOCATION_UPDATED"
let NOTIFICATION = "NOTIFICATIONS"
let SUBSCRIPTION = "SUBSCRIPTION"
let LOCATION_NOT_UPDATED = "LOCATION_NOT_UPDATED"
let GETPREBOOKINGACCEPTED = "PREBOOKING_ACCEPTED"
let SATRTANIMATE = "SATRTANIMATE"

let socketUrl = "http://52.8.169.78:7042/"
let baseUrl = "http://52.8.169.78:7029/"
//let baseUrl = "http://devpanel.wav.com.sg:3000/"
//let socketUrl = "http://devpanel.wav.com.sg:3002/"



//let baseUrl = "http://52.76.76.250:3001/"
//let imgUrl = "http://52.76.76.250/uploads/users/"
let imgUrl = "http://52.8.169.78:7029"

var topViewController: UIViewController!
let NO_INTERNET = "No Internet Connection"
let SERVER_ERROR = "Server Error"
var mfSideMenuContainerViewController:MFSideMenuContainerViewController!
var appName = "Driver App"

struct DateFormate {
    
    static let utcDateWithTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let dateWithTime = "dd-MM-yyyy, hh:mm a"
    static let dateOnly = "dd-MM-yyyy"
    static let timeOnly = "hh:mm a"
}

struct TimeZoneString {
    
    static let UTC = "UTC"
    static let SGT = "SGT"
}


var baseTabBarController: BaseTabBarController?{

    if let mfsisideVC = mfSideMenuContainerViewController{
        let navVC = mfsisideVC.centerViewController as! UINavigationController
        let rootVC = navVC.viewControllers.first
        if rootVC is BaseTabBarController{
            return rootVC as? BaseTabBarController
        }
    }
    return nil
}

let alertMessage = "Are you sure, you want to cancel ride?"

//MARK:- API keys


struct  APIKeys{
    
    static let googleMapsApiKey = "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"

    static let googleAPIKey = "AIzaSyCpvhVhEb0N4ihzWh8FA3FIVsdBEBGuESU"

    static let stripApiKey = "pk_test_HzItPOuiCYqH1a1Qym3iseif"
    //static let stripApiKey = "pk_live_48UGAiSE7wjqd8K4zYyTmnms"

}

struct NetworkIssue {
    static let slow_Network = "Internet Connection Slow"
}



//MARK:- Storyboard Names
//MARK:-


struct  StoryboardName{
    
    static let Main = "Main"
    static let User = "User"
    static let Subscription = "Subscriptions"

}

//MARK:- Static Keys
//MARK:-

struct  NSUserDefaultKey{
    
    static let LOGIN = "isLoggedIn"
    static let DeviceTokenn = "deviceTokenn"
    static let SystemVersion = "systemVersion"
    static let UserId = "userId"
    static let UserInfoDict = "userInfoDict"


}


//MARK:- Image Names
//MARK:-

struct ImageName{
    static let UNCHECK_IMAGE_STR = "UncheckRememberMe"
    static let CHECH_IMAGE_STR = "CheckRememberMe"
}

//MARK:- Static Fonts
//MARK:-

struct FontName{
    static let APP_COMMONFONT_BOLD = "aquawax-bold"
    static let APP_COMMONFONT_REGULAR = "aquawax-book"
}



//MARK:- Web Service URLs
//MARK:-



struct  URLName{

    static let SignUpApiUrl = baseUrl+"user/signup"
    static let LoginApiUrl = baseUrl + "user/login"
    static let ForgotPasswordApiUrl = baseUrl+"user/forgotpassword"
    static let validateforgotUrl = baseUrl+"user/validateforgot"
    static let VerifyOtpApiUrl = baseUrl+"user/userverifyotp"
    static let ChangePasswordUrl = baseUrl+"user/changepassword"
    static let SendOTPUrl = baseUrl+"user/userresendotp"
    static let LogoutUrl = baseUrl+"user/logout"
    static let AddVehicleUrl = baseUrl+"user/updatevehicles"
    static let googlePlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let googleGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
    static let placeDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json"
    static let rideNowUrl = baseUrl+"user/ridenow"
    static let getvehicleUrl = baseUrl+"user/vehicles"
    static let editProfileUrl = baseUrl+"user/usereditprofile"
    static let staticPagesUrl = baseUrl+"user/getpage"
    static let postQueryUrl = baseUrl+"user/query"
    static let driverStatusUrl = baseUrl+"user/currentstatus"
    static let changeDestination = baseUrl+"user/changelocation"
    static let rateUrl = baseUrl+"user/rate"
    static let promotionUrl = baseUrl+"user/promotions"
    static let saveLocationUrl = baseUrl+"user/savedlocations"
    static let scheduleUrl = baseUrl+"user/scheduleride"
    static let rideHistoryURL = baseUrl+"user/ridehistory"
    static let SubsViewCouponsURL = baseUrl+"user/generatecoupons"
    static let shareCoupon = baseUrl+"user/couponShareUser"
    static let myTransURL = baseUrl+"user/mytransactions"
    static let subsPaymentURL = baseUrl+"user/addUsermoney"
    static let getPreviousLocs = baseUrl+"user/previouslocs"
    static let applyCouponsURL = baseUrl+"user/verifycoupon"
    static let addUserCardURL = baseUrl+"user/addCard"
    static let saveCardDetailURL = baseUrl+"user/saveCards"
    static let removeSaveCardDetailURL = baseUrl+"user/removeCard"
    static let regainstateURL = baseUrl+"user/regainstate"
    static let rideActionURL = baseUrl+"user/rideaction"
    static let getFare = baseUrl+"user/estimatedfare"
    static let notificationstatusURL = baseUrl+"user/setNotificationStatus"
    static let availableCouponsURL = baseUrl+"user/myCoupons"
    static let notificationURL = baseUrl+"user/notifications"
    static let setDefaultPaymentMethodURL = baseUrl+"user/setdefaultpayment"
    static let editprofileURL = baseUrl+"user/editprofile"
}

//struct  URLName{
//    
//    static let SignUpApiUrl = baseUrl+"api/usersignup"
//    static let LoginApiUrl = baseUrl+"api/userlogin"
//    static let ForgotPasswordApiUrl = baseUrl+"api/userforgotpassword"
//    static let VerifyOtpApiUrl = baseUrl+"api/userverifyotp"
//    static let ChangePasswordUrl = baseUrl+"api/userchangepassword"
//    static let SendOTPUrl = baseUrl+"api/userresendotp"
//    static let LogoutUrl = baseUrl+"api/userlogout"
//    static let AddVehicleUrl = baseUrl+"api/updatevehicles"
//    static let googlePlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
//    static let googleGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
//    static let placeDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json"
//    static let rideNowUrl = baseUrl+"api/ridenow"
//    static let getvehicleUrl = baseUrl+"api/getvehicle"
//    static let editProfileUrl = baseUrl+"api/usereditprofile"
//    static let staticPagesUrl = baseUrl+"api/getpage"
//    static let postQueryUrl = baseUrl+"api/postquery"
//    static let driverStatusUrl = baseUrl+"api/currentstatus"
//    static let changeDestination = baseUrl+"api/changelocation"
//    static let rateUrl = baseUrl+"api/rate"
//    static let promotionUrl = baseUrl+"api/promotions"
//    static let saveLocationUrl = baseUrl+"api/savedlocations"
//    static let scheduleUrl = baseUrl+"api/scheduleride"
//    static let rideHistoryURL = baseUrl+"api/ridehistory"
//    static let SubsViewCouponsURL = baseUrl+"api/GenrateCoupons"
//    static let shareCoupon = baseUrl+"api/couponShareUser"
//    static let myTransURL = baseUrl+"api/mytrnstion"
//    static let subsPaymentURL = baseUrl+"api/addUsermoney"
//    static let getPreviousLocs = baseUrl+"api/previouslocs"
//    static let applyCouponsURL = baseUrl+"api/verifycoupon"
//    static let addUserCardURL = baseUrl+"api/addUserCards"
//    static let saveCardDetailURL = baseUrl+"api/saveCards"
//    static let removeSaveCardDetailURL = baseUrl+"api/removeCard"
//    static let regainstateURL = baseUrl+"api/regainstate"
//    static let rideActionURL = baseUrl+"api/rideaction"
//    static let getFare = baseUrl+"api/estimatedfare"
//    static let notificationstatusURL = baseUrl+"api/notificationstatus"
//    static let availableCouponsURL = baseUrl+"api/myCoupons"
//    static let notificationURL = baseUrl+"api/notifications"
//    static let setDefaultPaymentMethodURL = baseUrl+"api/setdefaultpayment"
//
//}


struct VehicleRelatedString {

    static let vehicleModel = "Enter Vehicle Model"
    static let vehicleType = "Select Vehicle Type"
    static let vehicleNo = "Enter Vehicle Number"
    static let vehicleAdded = "Vehicle Added"

}


struct RideRelatedString {
    
    static let selectDrop = "Please select drop location"
    static let selectDate_time = "Please select date and time"
    static let drop_loc_Limt = "Cannot add more location"
    static let selectPic = "Choose your Pick Up"
    static let changeDest_selectLoc = "Select Location"
    static let changeDest_updatedLoc = "Drop-off Destination Updated !"
    static let changeDest_rejected = "Change route request rejected !"

    static let share_eta_Msg = "You'll reach to your destination in"
    static let arrivalnow_share_eta_Msg = "Your driver will arrive in"


    
}


struct ChangePasswordStrings {
    
    static let currentPass = "Please fill the current Password"
    static let newPass = "Please fill New password"
    static let confirmPass = "Confirm New Password"
    
    static let passMinLength = "password length should be more than 6 characters"
    static let passMaxLength = "password length should not be more than 32 characters"
    static let matchPass = "Current password and Confirm password cannot be same"
    static let notMatchPass = "Current password and Confirm password cannot be same"
    
    static let newPass_confirmPass_NotMatch = "New password and Confirm password cannot be same"
    
    static let currentPass_confirmPass_NotMatch = "Current password and Confirm password cannot be same"

}


struct ProfileStrings {
    
    static let enter_name = "Please enter the Name"

    
    static let nameRequired = "Name is required"
    static let enterMobile = "Please enter the Mobile Number"
    static let selectCountryCode = "Please select country code"
    static let validMobile = "Please enter valid Mobile Number"
    
    // profile SetUp
    
    static let trms_condition = "Please accept Terms & Conditions"
    static let email_not_change = "You cannot change your Email ID"

    // myVehicles
    static let vehicleNeed = "You need to have at least one vehicle!!"
    static let vehicleRemoved = "Removed"
    
    //Rating
    
    static let rating = "Please Rate the driver"

    //signUp
    
    static let enterPass = "Please enter the Password"
    
}


struct LoginPageStrings {
    
    static let enterCredentials = "Please enter the Credentials"
    static let enterEmail = "Please enter the Email"
    static let enterValidEmail = "Please enter a valid Email Address"
    static let enetrPass = "Please enter the Password"
    
    // otp varification
    
    static let eneter_otp = "Please enter the OTP"
    static let enetr_valid_otp = "Please enter valid OTP"

    // Apply Coupons

    static let enter_coupon = "Enter Coupon Code"

    // Enter Query
    static let enter_query = "Please enter your Query"

    
}

struct ChooseLocationTitle {
    
    static let pic = "CHOOSE YOUR PICKUP"
    static let drop = "CHOOSE YOUR DROPOFF"
    static let chooseDrop = "Choose your Drop Off"
    static let dropOff = "DROP_OFF"
}


struct PaymentMode {
    static let card = "Card"
    static let cash = "Cash"
}

struct VehicleType {
    static let car = "Car"
    static let bike = "Bike"
}

struct NavigationTitle {
    static let arrivalNow = "ARRIVING NOW"
    static let onRide = "ON RIDE"
    static let onTheWay = "ON THE WAY"

    
}

struct RideStateString {
    
    static let onride = "Onride"
    static let arrivalNow = "arrivalNow"
    static let rating = "rating"
    
    static let cancel = "CANCEl"
    static let changeDest = "CHANGE DESTINATION"
    
}


struct AppConstantString {
    static let rideCancel = "Ride Cancelled"
}


struct RatingParameters{
    
    static let terrible = "Terrible"
    static let bad = "Bad"
    static let ok = "Ok"
    static let good = "Good"
    static let excellent = "Excellent"
    
    // service parameter
    static let cleanliness = "Cleanliness"
    static let pickup = "Pickup"
    static let service = "Service"
    static let navigation = "Navigation"
    static let driving = "Driving"
    static let other = "Other"
    
}

struct RatingDescription{
    
    static let rate1 = "WHAT WENT WRONG?"
    static let rate2 = "WHAT WENT WRONG?"
    static let rate3 = "WHAT WENT WRONG?"
    static let rate4 = "WHAT COULD BE BETTER?"
    static let rate5 = "WHAT WENT WELL?"
}


struct AddCardString {
    
    static let enterAmount = "Please Enter Amount"
    static let lessAmount = "Amount cannot be less than $1"
    static let enterCardNo = "Enter Card Number"
    static let validCardNo = "Please enter valid Card Number"
    
    static let enterName = "Please enter Name on your card"
    static let enterMonth = "Enter Expiry Date"
    static let enterExpiry = "Enter Card Expiry Date"
    
    static let enterYear = "Enter Expiry Year"
    static let enterCvv = "Enter CVV"
    static let validCvv = "Please enter valid CVV number"
    
}


struct SubsCriptionStrings {
    
    static let card_detail_Navi_title = "CARD DETAIL"
    static let card_detail = "Card Detail"
    static let card_detail_Descrition = "Enter your Debit card or Credit card Details"
    static let card_detail_Select_Card = "Select Card"
    static let addAmount_Navi_title = "ADD AMOUNT"
    static let addAmount_Available_Amnt = "AMOUNT AVAILABLE"
    static let addAmount_Enter_Amnt = "Enter Amount"
    static let subscription_Last_trans = "LAST TRANSACTION"
    static let subscription_Coupons_Navi_Title = "COUPONS"

}



struct Status {
    
    static let one = "1"
    static let two = "2"
    static let three = "3"
    static let four = "4"
    static let five = "5"
    static let six = "6"
    static let seven = "7"
    static let eight = "8"
    static let nine = "9"
    static let zero = "0"
}


//MARK:- Array of Type
//MARK:-



//Categories Types
