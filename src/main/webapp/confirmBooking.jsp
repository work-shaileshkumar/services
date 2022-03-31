<!-- For partners pages -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" errorPage="serverError.jsp"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, com.zylkerservices.CustomerRepository, com.zylkerservices.Customer, com.zylkerservices.PartnerRepository" %>
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
	    int userId = (Integer)jwt.get("user_id");
	    HashMap<String, Object> orderCharges = (HashMap) request.getAttribute("orderCharges");
	    String partnerName = (String) orderCharges.get("partner_name");
	    String serviceName = (String) orderCharges.get("service_name");
	    String serviceLocation = (String) orderCharges.get("service_location");
	    int serviceCharge = (Integer) orderCharges.get("order_value");
	    double tax = (Double) orderCharges.get("tax");
	    double bookingCharge = (Double) orderCharges.get("booking_charges");
	    double totalCharges = (Double) orderCharges.get("total_charges");
	    double walletBalance = CustomerRepository.getWalletBalance(userId);
	    double lockedWalletBalance = CustomerRepository.getLockedWalletBalance(userId);
	    walletBalance -= lockedWalletBalance;
	    Customer customer = CustomerRepository.getCustomerProfileInfo(userId);
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
<title>Confirm your booking</title>
<style>
  .card {
    border: 1px solid black;
  }
  #goBackBtn {
    border: 2px solid black;
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
	<div class="container" style="margin-top: 25px;">
	  <div class="row">
	     <div class="row" style="margin-top: 20px;">
	       <div class="col-6">
			  <div class="card shadow-lg p-3 mb-5 bg-body rounded">
				  <div class="container m-3" style="margin-top: 30px;">
				    <h5><b>Partner Details,</b></h5>
				    <table style="margin-top: 30px;" class="table">
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Partner Name:</th>
				          </div>
				          <div class="col-6">
				            <td><%= partnerName %></td>
				          </div>
				        </div>
				      </tr>
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Service:</th>
				          </div>
				          <div class="col-6">
				            <td><%= serviceName %></td>
				          </div>
				        </div>
				      </tr>
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Service Location:</th>
				          </div>
				          <div class="col-6">
				            <td><%= serviceLocation %></td>
				          </div>
				        </div>
				      </tr>
				    </table>
				    <h5 style="margin-top: 50px;"><b>Your Details,</b></h5>
				    <table style="margin-top: 30px;" class="table">
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Name:</th>
				          </div>
				          <div class="col-6">
				            <td><%= customer.getCustomer_name() %></td>
				          </div>
				        </div>
				      </tr>
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Contact Number:</th>
				          </div>
				          <div class="col-6">
				            <td><%= customer.getCustomer_phno() %></td>
				          </div>
				        </div>
				      </tr>
				      <tr>
				        <div class="row">
				          <div class="col-6">
				            <th>Email-id:</th>
				          </div>
				          <div class="col-6">
				            <td><%= customer.getCustomer_email() %></td>
				          </div>
				        </div>
				      </tr>
				    </table>
				  </div>
			  </div>
			</div>
	       <div class="col-6">
	         <div class="card shadow-lg p-3 mb-2 bg-body rounded">
	           <div class="container-fluid m-1">
	             <h5>Fare Breakup</h5>
	             <table class="table" style="margin-top: 30px;">
	               <tr>
	                 <th>Service Charge</th>
	                 <td>
	                   <div class="row">
	                     <div class="col-6"><b><%= serviceCharge %></b></div>
	                     <div class="col-6">INR</div>
	                   </div>
	                 </td>
	               </tr>
	               	<tr>
	                 <th>GST (18%)</th>
	                 <td>
	                   <div class="row">
	                     <div class="col-6"><b><%= tax %></b></div>
	                     <div class="col-6">INR</div>
	                   </div>
	                 </td>
	               </tr>
	               	<tr>
	                 <th>Booking Charge (2%)</th>
	                 <td>
	                   <div class="row">
	                     <div class="col-6"><b><%= bookingCharge %></b></div>
	                     <div class="col-6">INR</div>
	                   </div>
	                 </td>
	               </tr>
	               <tr>
	                 <th style="color: #f75a4f;"><b>Total Booking Charge</b></th>
	                 <td style="color: #f75a4f;">
	                   <div class="row">
	                     <div class="col-6"><b id="totalCharges"><%= totalCharges %></b></div>
	                     <div class="col-6"><b>INR</b></div>
	                   </div>
	                 </td>
	               </tr>
	             </table>
	           </div>
	         </div>
	         <div class="card mt-4 shadow-lg bg-body rounded">
	           <div class="container-fluid m-1">
	             <h5 class="mt-1">Wallet Breakup</h5>
	             <table class="table" style="margin-top: 30px;">
	               <tr>
	                 <th>Current Wallet Balance</th>
	                 <td>
	                   <div class="row">
	                     <div class="col-6"><b><%= String.format("%.2f",walletBalance) %></b></div>
	                     <div class="col-6">INR</div>
	                   </div>
	                 </td>
	               </tr>
	               <%
	                  if(walletBalance >= totalCharges) {
	               %>
	               <tr>
	                 <th>Wallet Balance After Order: </th>
	                 <td>
	                    <div class="row">
	                      <div class="col-6"><b><%= String.format("%.2f",walletBalance-totalCharges) %></b></div>
	                      <div class="col-6">INR</div>
	                    </div>
	                 </td>
	               </tr>
	               <%
	                  } else {
	               %>
	               <tr>
	                 <th>You still need: </th>
	                 <td>
	                    <div class="row">
	                      <div class="col-6"><b><%= String.format("%.2f",(double) Math.abs(walletBalance-totalCharges)) %></b></div>
	                      <div class="col-6">INR</div>
	                    </div>
	                 </td>
	               </tr>
	               <%
	                  }
	               %>
	             </table>
	           </div>
	         </div>
	         <%
	           if(walletBalance >= totalCharges) {
	         %>
	             <button class="btn btn-block col-12 mt-5" id="confirmBookingBtn" style="background-color: #d4ca48; color: black; border: 2px solid black;">Confirm My Booking &nbsp; <img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_forward_ios_black_24dp_W8p3cCQEd.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648614356490" width="25px;" height="25px;" /><img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_forward_ios_black_24dp_W8p3cCQEd.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648614356490" width="25px;" height="25px;" /></button>
	         <%
	           } else {
	         %>
	           <div class="row" style="margin-left: 20px;">
	             <a href="/zylkerservices/account/wallet?add_amount=<%= PartnerRepository.findNearestAmount(Math.abs(walletBalance-totalCharges)) %>" class="btn btn-block col-6 mt-5" style="background-color: #d4ca48; color: black; border: 2px solid black; margin-right: 10px;">Continue booking by adding <%= PartnerRepository.findNearestAmount(Math.abs(walletBalance-totalCharges)) %> INR to wallet <img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_forward_ios_black_24dp_W8p3cCQEd.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648614356490" width="25px;" height="25px;" /><img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_forward_ios_black_24dp_W8p3cCQEd.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648614356490" width="25px;" height="25px;" /> </a> 
	             <button class="btn btn-block col-5 mt-5" id="goBackBtn">I've changed my mind<br/>Go back &nbsp; <img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_back_ios_black_24dp_jbz2QtIog.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648625716118" width="25px;" height="25px;" /><img src="https://ik.imagekit.io/lgqbj7lz15u/outline_arrow_back_ios_black_24dp_jbz2QtIog.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648625716118" width="25px;" height="25px;" /></button> 
	           </div>                                                
	         <%
	           }
	         %>
	</div>
	<div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

let xhr = new XMLHttpRequest();

window.onload = function() {
	
	let params = new URL(location).searchParams;
	if(params.get("confirmBooking")!=null)
	{
		if(params.get("confirmBooking")=="true")
		{
		    document.getElementById("confirmBookingBtn").click();
		}
	}
}

if(document.getElementById("goBackBtn")!=null)
{
	document.getElementById("goBackBtn").addEventListener("click",function(){
		location.replace(document.referrer == location.href ? "/zylkerservices/index.jsp" : document.referrer);
	});	
}

if(document.getElementById("confirmBookingBtn")!=null)
{
	document.getElementById("confirmBookingBtn").addEventListener("click",function(){
		console.log(document.getElementById("totalCharges").innerText);
		let params = new URL(location).searchParams;
		let data = {
				"partner_id": Number(params.get("partnerId")),
				"service_name": params.get("serviceName"),
				"service_location": params.get("serviceLocation"),
				"total_charges": Number(document.getElementById("totalCharges").innerText),
				"csrf": document.getElementById("csrf").value
		};
		let origin = location.origin;
		let path = "/zylkerservices/account/orders?action=create_new_order";
		xhr.open("POST",(origin+path));
		xhr.send(JSON.stringify(data));
		xhr.onreadystatechange = function() {
		  if(this.readyState == 4)
		  {
			  if(this.status == 400)
		         location.replace("/zylkerservices/partnerNoAccessPage.jsp");
			  else if(this.status == 202)
				 location.replace("/zylkerservices/orderCreated.jsp"); 
		  }
		}
	});	
}

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