<%@ page language="java" contentType="text/html; charset=UTF-8" errorPage="serverError.jsp" pageEncoding="UTF-8"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, com.zylkerservices.PartnerRepository" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="google-signin-client_id"
		content="401866588161-ia8dho0lbmgppc06er4ccpll0p9lfqt3.apps.googleusercontent.com">
	<!-- Bootstrap CSS -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet"
		integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
	<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
	<script src="https://apis.google.com/js/platform.js" async defer></script>
	<%
	    HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
	    if(jwt==null || !jwt.get("user_role").equals("partner")) {
	    	response.sendRedirect("index.jsp");
	    }
	    int partnerId = (int) jwt.get("user_id");
	    boolean isPremiumUser = PartnerRepository.checkSubscriptionStatus(partnerId);
	    if(isPremiumUser)
	    	response.sendRedirect("analytics.jsp");
		boolean signedIn = false;
		Cookie[] cookies = request.getCookies();
		String signedInUserRole = "";
		if (cookies != null) 
		{
			for (Cookie cookie : cookies) 
			{
				if (cookie.getName().equals("Z_AUTHUSER")) 
				{
					signedIn = true;
					String[] cookie_value = cookie.getValue().split("-");
					signedInUserRole = cookie_value[1].equals("C") ? "customer" : cookie_value[1].equals("P") ? "partner" : "admin";
				}
			}
		}
	%>
<title>Buy premium</title>
<style>
 .card{
   border: 2px solid lightgrey;
 }
</style>
</head>
<body>
    	<nav class="navbar sticky-top navbar-light" style="background-color: rgb(4, 4, 92);">
		<div class="container-fluid">
			<div class="row">
				<div class="float-left">
					<a class="navbar-brand text-white" style="margin-left: 20px;" href="/zylkerservices/index.jsp">Zylker Services</a>
				</div>
			</div>
			<div class="row">
				<div class="float-right">
				            <%
                if(!signedIn)
                {
             %>
            <button type="button" class="btn btn-primary btn-sm"
              style="margin-right: 20px; border-radius: 60px; background-color: rgb(4, 4, 92);" data-bs-toggle="modal"
              data-bs-target="#loginModal">Sign
              In</button>
            <%
                }
                else
                {
                	if(signedInUserRole.equals("customer"))
                	{
            %>
            <a href="/zylkerservices/account/myorders"  class="btn btn-sm text-white" style="margin-right: 25px;">My Orders</a>
            <a href="/zylkerservices/account/favourites"  class="btn btn-sm text-white" style="margin-right: 25px;">Favourites</a>
            <a href="/zylkerservices/account/wallet"  class="btn btn-sm text-white" style="margin-right: 25px;">Wallet</a>
            <a href="/zylkerservices/account"  class="btn btn-sm text-white" style="margin-right: 25px;">My Account</a>
            <button onclick="signOut();"  class="btn btn-sm text-white" style="margin-right: 5px;">Sign Out</button>
            <input type="text" name="csrf" id="csrf" value="<%= jwt==null ? "" : jwt.get("csrf") %>" contenteditable="false" style="display:none" />
            <%
                	}
                	else if(signedInUserRole.equals("partner"))
                	{
            %>
            <a href="/zylkerservices/account/analytics" class="btn btn-sm text-white" style="margin-right: 25px;">Analytics</a>
			<a href="/zylkerservices/account/myorders" class="btn btn-sm text-white" style="margin-right: 25px;">Orders</a>
			<a href="/zylkerservices/account/transactions" class="btn btn-sm text-white" style="margin-right: 25px;">Transactions</a>
			<a href="/zylkerservices/account" class="btn btn-sm text-white" style="margin-right: 25px;">My Account</a>
			<button onclick="signOut()" class="btn btn-sm text-white" style="margin-right: 5px;">Sign Out</button>
			<input type="text" name="csrf" id="csrf" value="<%= jwt==null ? "" : jwt.get("csrf") %>" contenteditable="false" style="display:none" />
            <%    		
                	}
                	else if(signedInUserRole.equals("admin"))
                	{
            %>
            <a href="/zylkerservices/account?page=manage.jsp" class="btn btn-sm text-white" style="margin-right: 25px;">Manage</a>
            <a href="/zylkerservices/account?page=adminAnalytics.jsp" class="btn btn-sm text-white" style="margin-right: 25px;">Analytics</a>
		    <a href="/zylkerservices/account?page=adminReports.jsp" class="btn btn-sm text-white" style="margin-right: 25px;">Reports</a>
		    <button onclick="signOut()" class="btn btn-sm text-white" style="margin-right: 5px;">Sign Out</button>
            <input type="text" name="csrf" id="csrf" value="<%= jwt==null ? "" : jwt.get("csrf") %>" contenteditable="false" style="display:none" />
            <% 
                	} 
                }
            %>
				</div>
			</div>
		</div>
	</nav>
	<input value="<%= partnerId %>" id="partnerId" style="display: none"/> 
	<div class="container">
	  <div class="row" style="margin-top: 50px;">
	    <div class="text-cente">
	      <h4 class="text-center">Upgrade to premium to know who viewed your profile</h4>
	      <div class="container">
	        <div class="row" style="margin-top: 60px;">
	           <div class="col-4 offset-4">
	             <div class="card mt-5">
	               <div class="m-2">
	                 <h5>Premium Partner</h5>
	                 <ul class="mt-4">
	                   <li>Access to who viewed your profile</li>
	                 </ul>
	                 <div class="row m-3">
	                   <button class="btn btn-primary mt-5" id="buyPremium">Buy Now (1000 INR per month)</button>
	                 </div>
	               </div>
	             </div>
	           </div>
	        </div>
	      </div>
	    </div>
	  </div>
	</div>
</body>
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

let xhr = new XMLHttpRequest();
document.getElementById("buyPremium").addEventListener("click",function(){
	//document.getElementById("loadingImage").innerHTML = '<img src="https://ik.imagekit.io/lgqbj7lz15u/Rolling-1s-200px_NTllp7DPH.svg?ik-sdk-version=javascript-1.4.3&updatedAt=1647514281912" width="22px" height="22px" style="margin-left: 4px; margin-bottom: 2px;" />';  
	let origin = location.origin;
	let path = "/zylkerservices/account/wallet?action=buy_premium";
	let data = {
			"csrf": document.getElementById("csrf").value,
			"amount": 1000
	};
	xhr.open("POST",(origin+path));
	xhr.send(JSON.stringify(data));
	xhr.onreadystatechange = function(){
		if(this.status == 200 && this.readyState == 4)
		{
			let razorPayResponse = JSON.parse(this.responseText);
			console.log(razorPayResponse);
			var options = {

				"amount" : razorPayResponse.amount,
				"currency" : "INR",
				"name" : "Zylker Services",
				"description" : "Add Amount To Zylker Wallet",
				"order_id" : razorPayResponse.id,
			    "handler": function (response){
			    	//document.getElementById("loadingImage").innerHTML = "";
			        let verifyPaymentPath = "/zylkerservices/account/wallet?action=verify_payment";
			        let paymentVerifyXHR = new XMLHttpRequest();
			        paymentVerifyXHR.open("POST",(origin+verifyPaymentPath));
			        let paymentData = {
			        	"payment_id": response.razorpay_payment_id,
			        	"order_id": response.razorpay_order_id,
			        	"signature": response.razorpay_signature,
			            "amount": razorPayResponse.amount,
			        	"csrf": document.getElementById("csrf").value
			        };
			        paymentVerifyXHR.send(JSON.stringify(paymentData));
			        paymentVerifyXHR.onreadystatechange = function() {
			        	if(paymentVerifyXHR.readyState == 4 && paymentVerifyXHR.status == 200)
			        	{
			        		let paymentVerificationResponse = JSON.parse((paymentVerifyXHR.responseText));
			        		console.log(paymentVerificationResponse)
			        		let premiumXHR = new XMLHttpRequest();
			        		let origin = location.origin;
			        		let path = "/zylkerservices/account/wallet?action=add_to_premium";
			        		let partnerId = Number(document.getElementById("partnerId").value);
			        		premiumXHR.open("POST",(origin+path));
			        		let data = {
			        			"partner_id": partnerId
			        		};
			        		premiumXHR.send(JSON.stringify(data));
			        		premiumXHR.onreadystatechange = function() {
			        			if(premiumXHR.readyState == 4 && premiumXHR.status == 202) {
			        		        alert(paymentVerificationResponse);
			        	            location.replace("/zylkerservices/account/analytics");
			        	            alert();
			        			}
			        		}
			        	}
			        }
			    },
				"prefill" : {
				"name" : razorPayResponse.notes.name,
					"email" : razorPayResponse.notes.email,
					"contact" : razorPayResponse.notes.phno
				}
			};
			var rzp1 = new Razorpay(options);
			rzp1.open();
			rzp1.on('payment.failed', function(response) {
				alert("Payment Failed");
				location.reload();
			});
		}
	}
});
function signOut() {
    let cookie = document.cookie;
    let auth_type = cookie.substring(cookie.indexOf("Z_AUTHUSER="))[11];
    if(auth_type == 'G')
    {
          var auth2 = gapi.auth2.getAuthInstance();
          auth2.signOut().then(function () {
            
        });
    }
    let origin = location.origin;
    let path = "/zylkerservices/user?service=signout&csrf="+document.getElementById("csrf").value;
    xhr.open("POST", (origin + path));
    xhr.send();
    xhr.onreadystatechange = function() {
    	if(this.readyState == 4 && this.status==200)
    	{
    		location.replace("/zylkerservices/index.jsp");
    	}
    }
  }
  
  function onLoad() {
      gapi.load('auth2', function() {
        gapi.auth2.init();
      });
    }

</script>
<script src="https://apis.google.com/js/platform.js?onload=onLoad" async defer></script>
</html>