<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, java.util.List" %>
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
	<link rel="stylesheet" href="/zylkerservices/loader.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
	<script src="https://apis.google.com/js/platform.js" async defer></script>
	<%
	    HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		boolean signedIn = false;
		Cookie[] cookies = request.getCookies();
		//out.println(request.getAttribute("favouritePartners"));
		List<HashMap<String, Object>> favouritePartners = (List) request.getAttribute("favouritePartners");
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
<title>My - Favourites</title>
<style>
.card {
  border: 2px solid lightgrey;
}
#viewMoreBtn, #viewMoreBtn:hover {
    background-color: #044275;
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
	<div class="container" id="bodyContent">
	   <%
	      if(favouritePartners.size()==0) { 
	   %>
	    <h4 style="margin-top: 210px; margin-left: 350px;">You haven't added any partners to your favourites list !</h4>
	   <%
	      } else {
	   %>
	   <div class="row" style="margin-top: 30px">
	        <%
	          for(HashMap<String, Object> favouritePartner:favouritePartners) {
	        	 int partnerId = (Integer) favouritePartner.get("partner_id");
	        	 String partnerName = (String) favouritePartner.get("partner_name");
	        	 String serviceName = (String) favouritePartner.get("service_name");
	        	 String serviceLocation = (String) favouritePartner.get("service_location");
	        	 int serviceCharge = (Integer) favouritePartner.get("service_charge");
	             String viewProfileHref = "/zylkerservices/partner?action=viewPartnerProfile&partnerId="+partnerId+"&serviceName="+serviceName+"&serviceLocation="+serviceLocation;
	             String partnerDpURL = favouritePartner.get("partner_dp_url")==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : (String) favouritePartner.get("partner_dp_url"); 
	       %>
			<div class="col-6">
				<div class="card m-3 shadow-lg p-3 mb-5 bg-body rounded">
					<div class="card-body m-1">  
					   <div class="row">
					      <div class="col-6">
					        <img src="<%= partnerDpURL %>" style="border-radius: 100px" height="100px;" width="100px;" />
					      </div>
					      <div class="col-6">
					        <h3 class="mt-3"><%= partnerName %></h3>
					      </div>
					   </div>
					   <div class="row mt-5">
					      <div class="col-6"><b style="font-size: 18px;">Service Name: </b><%= serviceName %></div>
					      <div class="col-6"><b style="font-size: 18px;">Service Location: </b><%= serviceLocation %></div>
					   </div>
					   <div class="row mt-5">
					      <div class="col-6"><b style="font-size: 18px;">Service Charge: </b><%= serviceCharge %></div>
					      <div class="col-6 d-grid gap-2"><a href="<%= viewProfileHref %>" class="btn btn-sm btn-block" style="text-decoration: none" id="viewMoreBtn" >View More</a></div>
					   </div>
					</div>
				</div>
			</div>
		<%
		}
		%>
		</div>
		<%
	      }
		%>
	</div>
	<div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script>
	let xhr = new XMLHttpRequest();
	function signOut() {
		let cookie = document.cookie;
		let auth_type = cookie.substring(cookie.indexOf("Z_AUTHUSER="))[11];
		if (auth_type == 'G') {
			var auth2 = gapi.auth2.getAuthInstance();
			auth2.signOut().then(function() {

			});
		}
		let origin = location.origin;
		let path = "/zylkerservices/user?service=signout&csrf="
				+ document.getElementById("csrf").value;
		xhr.open("POST", (origin + path));
		xhr.send();
		xhr.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
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