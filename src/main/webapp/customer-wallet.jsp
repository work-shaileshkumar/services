<%@ page language="java" contentType="text/html; charset=UTF-8" errorPage="serverError.jsp" pageEncoding="UTF-8"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, com.zylkerservices.CustomerRepository, java.util.List, com.zylkerservices.Security" %>
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
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="stylesheet" href="/zylkerservices/loader.css">
	<script src="https://apis.google.com/js/platform.js" async defer></script>
	<%
	    HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
	    int customer_id = (Integer) jwt.get("user_id");
	    List<HashMap<String, Object>> customerTransactions = (List<HashMap<String, Object>>) CustomerRepository.getAllCustomerTransactions(customer_id);
	    double walletBalance = CustomerRepository.getWalletBalance(customer_id);
	    double lockedWalletBalance = CustomerRepository.getLockedWalletBalance(customer_id);
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
        boolean accountCreated = session.getAttribute("name") == null ? false : true;
        if(!accountCreated && signedIn)
        	response.sendRedirect("/zylkerservices/account?display=account_not_created");
	%>
<title>Wallet</title>
<style>
#addMoneyBtn {
  background-color: #fc8c03;
  color: white;
}
</style>
</head>
<body style="background-color: #f2f2f2;">
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
	<!-- add money to wallet start -->
	<div class="modal fade" id="addMoneyModal" tabindex="-1"
		aria-labelledby="addMoneyModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="addMoneyModalLabel">Add money to your wallet</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
				  <select class="form-select" id="amountToBeAdded">
				     <option selected disabled>Choose an amount to add</option>
				     <option>100</option>
				     <option>200</option>
				     <option>500</option>
				     <option>1000</option>
				     <option>2000</option>
				  </select>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
					<button type="button" class="btn btn-primary btn-sm" id="addMoneyToWallet">Add money <b id="loadingImage"></b></button>
				</div>
			</div>
		</div>
	</div>
	<!-- add money to wallet end -->
	<div class="container">
	  <div class="row">
	    <h4 class="mt-4">Transactions,</h4>
	    <div class="col-8">
	         <!--  -->
	         <%
	            if(customerTransactions.size() == 0) {
	         %>
	             <h4 style="margin-top: 220px; margin-left: 300px;">No Transaction yet !</h4>
	         <%
	            } else {
	         %>
	             <%
	               for(HashMap<String, Object> customerTransaction: customerTransactions) { 
	             %>
	             <div class="card m-5 shadow-lg p-3 mb-5 bg-body rounded">
	               <div class="container m-4">
	                 <div class="row">
	                    <% 
	                      if(customerTransaction.get("partner_name")==null) { 
	                    %>
	                      <div class="col-6"><b>&nbsp; </b><b style="color: green">Added to wallet</b></div>
	                    <% 
	                      } else { 
	                    %>
	                      <div class="col-6 mt-3"><b>Paid to: &nbsp;</b><b style="color: red"><%= customerTransaction.get("partner_name") %></b></div>
	                    <%
	                      }
	                    %>
	                    <% 
	                      if(customerTransaction.get("partner_name")==null) { 
	                    %>
	                      <div class="col-6"><b>Amount: &nbsp; </b><b style="color: green">+<%= customerTransaction.get("transaction_value") %></b></div>
	                    <% 
	                      } else { 
	                    %>
	                      <div class="col-6"><b>Service Charge:</b>&nbsp; <b style="color: red"><%= customerTransaction.get("transaction_value") %></b></div>
	                    <%
	                      }
	                    %>
	                 </div>
	                 <div class="row mt-3">
	                   <div class="col-6"><b></b></div>
	                   <div class="col-6"><b>Transaction Time:</b> &nbsp; <%= customerTransaction.get("transaction_time") %></div>
	                 </div>
	               </div>
	             </div>
	             <%
	               }
	             %>
	           <%
	            } 
	           %>

	         <!--  -->
	    </div>
	    <div class="col-4">
	       <div class="card m-5 shadow-lg p-3 mb-5 bg-body rounded">
	          <div class="container m-2">
	            <h4>Wallet Balance</h4>
	            <p style="margin-top: 25px; font-size: 20px;"><b><%= String.format("%.2f",walletBalance-lockedWalletBalance) %></b> &nbsp; INR</p> 
	            <h5>Locked Wallet Balance</h5>
	            <p style="margin-top: 20px; font-size: 20px;"><b><%= String.format("%.2f",lockedWalletBalance) %></b> &nbsp; INR</p> 
	            <div class="text-center row" style="margin-top: 40px; margin-bottom: 20px; margin-right: 8px;" ><button class="btn" id="addMoneyBtn" data-bs-toggle="modal" data-bs-target="#addMoneyModal">Add Money to Wallet</button></div>
	          </div>
	       </div>
	    </div>
	  </div>
	</div>
	<div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

let xhr = new XMLHttpRequest();
var fromOtherPage = false;
window.onload = function() 
{
	let params = new URL(location).searchParams;
	let amount = Number(params.get("add_amount"));
	if(amount > 0)
	{
	    if(Number.isInteger(amount) && !fromOtherPage)
	    {
		    fromOtherPage = true;
	        document.getElementById("amountToBeAdded").value = amount;
	        document.getElementById("addMoneyToWallet").click();
	    }
	}
}

document.getElementById("addMoneyToWallet").addEventListener("click",function(){
	document.getElementById("loadingImage").innerHTML = '<img src="https://ik.imagekit.io/lgqbj7lz15u/Rolling-1s-200px_NTllp7DPH.svg?ik-sdk-version=javascript-1.4.3&updatedAt=1647514281912" width="22px" height="22px" style="margin-left: 4px; margin-bottom: 2px;" />';  
	let origin = location.origin;
	let path = "/zylkerservices/account/wallet?action=add_money_to_wallet";
	let data = {
			"csrf": document.getElementById("csrf").value,
			"amount": Number(document.getElementById("amountToBeAdded").value)
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
			    	document.getElementById("loadingImage").innerHTML = "";
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
			        	if(this.readyState == 4 && this.status == 200)
			        	{
			        		let paymentVerificationResponse = JSON.parse((paymentVerifyXHR.responseText));
			        		if(fromOtherPage)
			        		{
			        			location.replace(document.referrer+"&confirmBooking=true");
			        			console.log(document.referrer+"&confirmBooking=true");
			        		}
			        		else
			        		{
			        	        location.reload();
			        		}
			        	}	
			        }
			        location.reload();
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
				alert("payment failed");
				location.replace("/zylkerservices/index.jsp");
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
<script>
     $(window).on("load",function(){
        $(".loader-wrapper").fadeOut("slow");
    });
</script>
<script src="https://apis.google.com/js/platform.js?onload=onLoad" async defer></script>
</html>