<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="serverError.jsp" %>
<%@ page import = "com.zylkerservices.Partner, com.zylkerservices.UserRepository, com.zylkerservices.SearchService, java.util.HashMap" %>
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
	    HashMap<String, Object> partner = (HashMap) request.getAttribute("partner_data");
	    HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt");
	    String imageSrcFavouritesLink = (Boolean) partner.get("favourite_partner")==true ? "https://ik.imagekit.io/lgqbj7lz15u/filled_heart_q_QonMAZw.png?ik-sdk-version=javascript-1.4.3&updatedAt=1647238200174" : "https://ik.imagekit.io/lgqbj7lz15u/outline_heart_YaL6YJ2zVuQF.png?ik-sdk-version=javascript-1.4.3&updatedAt=1647238200171";
	    //out.println(partner);
	    int partnerId = (Integer) partner.get("partner_id");
	    String serviceName = (String) partner.get("service_name");
	    String serviceLocation = (String) partner.get("service_location");
	    String partnerName = (String) partner.get("partner_name");
        boolean signedIn = jwt==null ? false : true;
        if(!signedIn)
        	response.sendRedirect(request.getHeader("referer")==null ? "/zylkerservices/index.jsp" : request.getHeader("referer"));
        String signedInUserRole = jwt==null ? "" : (String) jwt.get("user_role");
        String confirmBookingHref = "/zylkerservices/account/orders?action=confirmBooking&partnerId="+partnerId+"&serviceName="+serviceName+"&serviceLocation="+serviceLocation+"&partnerName="+partnerName;
        String serviceImageHref = partner.get("service_image")==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : (String) partner.get("service_image");
        boolean accountCreated = session.getAttribute("name") == null ? false : true;
        if(!accountCreated && signedIn)
        	response.sendRedirect("/zylkerservices/account?display=account_not_created");
    %>
<title><%= partner.get("partner_name") %></title> 
<style>
 #bookNowBtn {
   background-color: #d4ca48;
   color: black;
 }
 #placeOrderBtn, #placeOrderBtn:hover {
     background-color: rgb(4, 4, 92);
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
	<!-- 
	 place order modal start
	 -->
	 <!-- Modal -->
	<div class="modal fade" id="createOrderModal" tabindex="-1" aria-labelledby="createOrderModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="createOrderModalLabel">Confirm Booking</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
				  <p></p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
					<button type="button" class="btn" id="placeOrderBtn">Place Order</button>
				</div>
			</div>
		</div>
	</div>
	<!-- 
	   place order modal end
	  -->
	<div class="container-fluid">
	  <div class="row" style="margin-top: 40px;">
	    <div class="col-6">
	       <img src = "<%=serviceImageHref %>" alt = "serviceImage" width="500px;" height="500px;" style="margin-left: 80px; margin-top: 30px;" />
	    </div>  
	    <div class="col-6">
	       <div class="row">
	         <div class="col-6">
	            <h4><%= partner.get("partner_name") %> </h4>
	         </div>
	         <div class="col-6">
	            <img src="<%= imageSrcFavouritesLink %>" id="favouritesBtn" alt="favourites_status" width="30px" height="30px" style="cursor: pointer" />             
	         </div>
	       </div>
	       <h5 style="margin-top: 40px;"><%= partner.get("service_charge")%> &nbsp; INR <p style="font-size: 14px; margin-top: 25px;"> + 18% gst + 2% booking charge (upto 20/-)</p></h5>
	       <table>
	         <tr>
	          	<th><h6 style="margin-top: 50px;">Service: </h6></th>
	         	<td><h6 style="margin-top: 50px; margin-left: 25px;"><%= partner.get("service_name") %></h6></td>
	         </tr>
	         <tr>
	           <th><h6 style="margin-top: 50px;">Location: </h6></th>
	           <td><h6 style="margin-top: 50px; margin-left: 25px;"><%= partner.get("service_location") %></h6></td>
	         </tr>
	         <tr>
	           <th><h6 style="margin-top: 50px;">Average Rating: </h6></th>
	           <td>
	             <h6 style="margin-top: 50px; margin-left: 25px;">
	             <% int rating = (int) (double) partner.get("partner_average_rating"); %>
	             <%for(int i=0;i<rating;i++) {%>&#9733;<% }%>
				 <%for(int i=rating;i<5;i++) {%>&#9734;<% }%>
	             </h6>
	           </td>
	         </tr>
	         <tr>
	           <th><h6 style="margin-top: 50px;">Verified Partner: </h6></th>
	           <td><h6 style="margin-top: 50px; margin-left: 25px;"> <%= (Boolean) partner.get("is_verified")==false ? "Not Yet" : "Verified" %> </h6></td>
	         </tr>
	       </table>
	       <div class="row" style="margin-top: 50px;"> 
	         <a href="<%= confirmBookingHref %>" class="col-6 offset-0 btn" id="bookNowBtn" style="letter-spacing: 1px;">Book Now</a>
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
	
document.getElementById("favouritesBtn").addEventListener("click",function(){
	
	let params = new URL(location).searchParams;
	let origin = location.origin;
	let path = "/zylkerservices/account?update=add_to_favourites";
	xhr.open("POST", (origin+path));
	let data = {
	        "service_name": params.get("serviceName"),
	        "service_location": params.get("serviceLocation"), 
			"partner_id": Number(params.get("partnerId")),
			"csrf": document.getElementById("csrf").value
	};
	xhr.onreadystatechange = function() {
		if(this.readyState==4 && this.status==200) 
		{
			location.reload();
		}
	}
	xhr.send(JSON.stringify(data));
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