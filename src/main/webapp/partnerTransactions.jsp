<%@ page language="java" contentType="text/html; charset=UTF-8" errorPage="serverError.jsp" pageEncoding="UTF-8"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, java.util.List, com.zylkerservices.PartnerRepository" %>
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
	    List<HashMap<String, Object>> partnerTransactions = (List<HashMap<String, Object>>)request.getAttribute("partnerTransactions");
		int partner_id = (Integer) jwt.get("user_id");
	    String[] revenueAndOrders = ((String)PartnerRepository.getTotalRevenueForTheDay(partner_id)).split("-");
	    int revenueToday = Integer.parseInt(revenueAndOrders[0]);
	    int ordersToday = Integer.parseInt(revenueAndOrders[1]);
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
<title>Transactions</title>
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
			<a href="/zylkerservices/account/myorders?limit=8" class="btn btn-sm text-white" style="margin-right: 25px;">Orders</a>
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
	<div class="container">
	  <h4 style="margin-top: 30px;">Your Transactions</h4>
	  <div class="row" style="margin-top: 50px;">
	    <div class="col-7">
		  <%
			if (partnerTransactions.size() == 0) {
		  %>
			<h5 style="margin-top: 200px; margin-left: 200px;">You don't have any transactions</h5>
		  <%
			}
		  %>
		  <%
	        for(HashMap<String, Object> partnerTransaction:partnerTransactions) {
	      %>
	      	<div class="card mt-4 shadow-lg p-3 mb-2 bg-body rounded">
	         <div class="container">
	           <div class="row">
	             <div class="col-6"><b>Customer Name: &nbsp; </b><%= partnerTransaction.get("customer_name") %></div>
	             <div class="col-6"><b>Customer Phno: &nbsp; </b><%= partnerTransaction.get("customer_phno") %></div>
	           </div>
	           <div class="row mt-4">
	             <div class="col-6"><b style="color: green">Transaction Value</b>: &nbsp;  <b><%= (Double) partnerTransaction.get("transaction_value")*-1.0 %> &nbsp; INR</b></div>
	             <div class="col-6"><b>Service:</b> &nbsp; "<%= partnerTransaction.get("service_name") %>" &nbsp; at &nbsp; "<%= partnerTransaction.get("service_location") %>"</div>
	           </div>
	           <div class="row mt-4">
	             <div class="col-6"><b>Order id: &nbsp; </b>#<%= partnerTransaction.get("order_id") %></div>
	             <div class="col-6"><b>Payment Received: &nbsp; </b><%= partnerTransaction.get("transaction_time") %></div>
	           </div>
	         </div>
	       </div>
	      <%
	        }
	      %>
	    </div>
	    <div class="col-5">
	      <div class="card m-4 shadow-lg p-3 mb-2 bg-body rounded">
	      <div class="container">
	        <div class="row m-3">
	          <div class="col-6 text-center"><b><h5>Revenue Today</h5></b></div>
	          <div class="col-6 text-center"><b><h5>Accepted Orders Today</h5></b></div>
	        </div>
	        <div class="row m-3">
	          <div class="col-6 text-center mt-3"><b><h5><%= revenueToday==-1 ? "N/A" : revenueToday %> &nbsp; INR</b></h5></div>
	          <div class="col-6 text-center mt-3"><b><h5><%= ordersToday==-1 ? "N?A" : ordersToday %></h5></b></div>
	        </div>
	      </div>
	      </div>
	    </div>
	  </div>
	</div>
	<div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

let xhr = new XMLHttpRequest();
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