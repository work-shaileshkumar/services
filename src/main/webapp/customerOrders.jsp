<%@ page language="java" contentType="text/html; charset=UTF-8" errorPage="serverError.jsp" pageEncoding="UTF-8"%>
<%@ page import = "java.util.HashMap, com.zylkerservices.UserRepository, com.zylkerservices.CustomerRepository, java.util.List, com.zylkerservices.PartnerRepository, java.sql.Timestamp, com.zylkerservices.OrderService" %>
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
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="stylesheet" href="/zylkerservices/loader.css">
	<script>function giveRating(orderId, customerId, partnerId){ submitRating(orderId, customerId, partnerId) }</script>
	<%
	    HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
	    List<HashMap<String, Object>> customerOrders = CustomerRepository.getAllCustomerOrders((Integer) jwt.get("user_id"));
		int customerId = (Integer) jwt.get("user_id");
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
<style>
  .card {
    border: 3px solid lightgrey;
  }
  .red {
    color: red;
  }
  .green {
    color: green;
  }
  .yellow {
    color: #d4ba55;
  }
  .cancelled {
     border-bottom: 2px solid red;
     border-right: 10px solid red;
  }
  .inprogress {
     border-bottom: 2px solid #ffb700;
     border-right: 10px solid #ffb700;
  }
  .accepted {
     border-bottom: 2px solid #038a1e;
     border-right: 10px solid #038a1e;
  }
  .rating-btn {
     background-color: #044275;
     color: white;
  }
  .rating-btn:hover {
     background-color: #044275;
     color: white;
  }
</style>
<title>My - Orders</title>
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
	<!-- ratings modal start -->
	<div class="modal fade" id="ratingsModal" tabindex="-1"
		aria-labelledby="ratingModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="ratingModalLabel">Submit your feedback</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>
				<div class="modal-body">
				   <p class="m-2">Rating</p>
				   <select class="form-select mt-1" id="rating">
				     <option selected disabled>Choose a rating</option>
				     <option>1</option>
				     <option>2</option>
				     <option>3</option>
				     <option>4</option>
				     <option>5</option>
				   </select>
				   <p class="m-2">Review</p>
				   <input placeholder="Share your experience" id="review" class="mt-1 form-control" type="text" /> 
				   <p style="color: red; margin-top: 15px;" id="submitRatingModalError"></p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
					<button type="button" id="submitReviewButton" class="btn btn-primary">Submit Review</button>
				</div>
			</div>
		</div>
	</div>
	<!-- ratings modal end -->
	<div class="container" style="margin-top: 50px;">
	  <div class="row">
	    <h4>Your Orders,</h4>
	    <%
	       if(customerOrders.size()==0) {
	    %>
	     <h4 style="margin-top: 220px; margin-left: 300px;">You haven't booked any services yet !</h4>
	    <%
	       } else {
	    %>
	     <div class="row">
	      <%
	        for(HashMap<String, Object> customerOrder:customerOrders) {
	        	int partnerId = (Integer) customerOrder.get("partner_id");
	        	String serviceImageHref = customerOrder.get("service_image")==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : (String) customerOrder.get("service_image");
	            String cardBorderClass = customerOrder.get("order_status").equals("cancelled by partner") ? "cancelled" : customerOrder.get("order_status").equals("accepted by partner") ? "accepted" : "inprogress"; 
	      %>
	      <div class="col-6">
	         <div class="card m-3 <%= cardBorderClass %> shadow-lg p-3 mb-5 bg-body rounded">
	            <div class="card-body">
	              <div class="row">
	                <div class="col-6"><img src="<%= serviceImageHref %>" width="70px;" height="70px;" style="border-radius: 10px;"/></div>
	                <div class="col-6"><h4><%= customerOrder.get("partner_name") %></h4>#<%= customerOrder.get("order_id") %></div>
	              </div>
	              <div class="row mt-4">
	                <div class="col-6"><b>Service Name:</b>  &nbsp; <%= customerOrder.get("service_name") %></div>
	                <div class="col-6"><b>Service Location:</b> &nbsp; <%= customerOrder.get("service_location") %></div>
	              </div>
	              <div class="row mt-4">
	                <div class="col-6"><b>Service Charge:</b> &nbsp; <%= OrderService.calculateExtraCharges((Integer)customerOrder.get("order_value"))+(Integer)customerOrder.get("order_value") %> INR</div>
	                <div class="col-6"><b>Last Updated:</b> &nbsp; <%= customerOrder.get("order_last_updated") %></div>
	              </div>
	              <div class="row mt-4">
	                <div class="col-6"><b>Order Created:</b> &nbsp; <%= customerOrder.get("order_created_date") %></div>
	                <div class="col-6"><b>Rating: &nbsp; </b>
	                  <%
	                     if(((Integer) customerOrder.get("order_rating"))!=0 && ((String) customerOrder.get("order_status")).contains("accepted")) {
	                  %>
	                  <text>You Rated <b><%= customerOrder.get("order_rating") %>&#9733;</b></text>
	                  <%
	                     } else if(((Integer) customerOrder.get("order_rating"))==0 && ((String) customerOrder.get("order_status")).contains("accepted")) {
	                  %>
	                  <button class="btn btn-sm rating-btn" style="width: 150px; margin-left: 10px; height: 30px;" onclick="javascript:giveRating(<%= customerOrder.get("order_id") %>, <%= customerId %>, <%= partnerId %>)" >Give Rating</button>
	                  <%
	                     } else if(((String) customerOrder.get("order_status")).contains("cancelled")) {
	                  %>
	                  <text>Order Cancelled</text>
	                  <%
	                     } else {
	                  %>
	                  <text>Not Available Yet</text>
	                  <%
	                     }
	                  %>
	                </div>
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
	</div>
	    <div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

let xhr = new XMLHttpRequest();

function submitRating(orderId, customerId, partnerId) 
{
	$("#ratingsModal").modal("toggle")
	document.getElementById("submitReviewButton").addEventListener("click",function(){
		if(!isNaN(Number(document.getElementById("rating").value)) &&  (document.getElementById("review").value).trim().length > 5)
		{
			let origin = location.origin;
			let path = "/zylkerservices/account/orders?action=submit_rating";
			xhr.open("POST",(origin+path));
			let data = {
				"rating": Number(document.getElementById("rating").value),
				"review": (document.getElementById("review").value).trim(),
				"order_id": orderId,
				"customer_id": customerId,
				"partner_id": partnerId,
				"csrf": document.getElementById("csrf").value
			};
			xhr.send(JSON.stringify(data));
			xhr.onreadystatechange = function()
			{
				if(this.readyState == 4 && this.status == 200)
				{
					location.reload();
				}
				else if(this.readyState == 4 && this.status == 401)
				{
					alert("Already Submitted rating");
				}
			}
		}
		else
		{
			let errorMsg = "";
			if(isNaN(Number(document.getElementById("rating").value)))
			{
				errorMsg = "Please select a value to rate from the drop down";
			}
			if((document.getElementById("review").value).trim().length <=  5)
			{
				if(errorMsg == "")
					errorMsg = "Your review should contain more than 5 characters";
				else
				    errorMsg += "and Your review should contain more than 5 characters"; 
			}
			document.getElementById("submitRatingModalError").innerText = errorMsg;
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