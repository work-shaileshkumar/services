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
	<script>
	function acceptOrder(orderId, customerId, orderTotalCharges, partnerId) { confirmOrder(orderId, customerId, orderTotalCharges, partnerId) }
	function cancelOrder(orderId, customerId, orderTotalCharges, partnerId) { rejectOrder(orderId, customerId, orderTotalCharges, partnerId) }
	history.scrollRestoration = "auto";
	</script>
	<%
	    HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		boolean signedIn = false;
		List<HashMap<String, Object>> partnerOrders = (List) request.getAttribute("partner_orders");
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
<title>My - Orders</title>
<style>
  .card {
    border-color: 10px solid light grey;
  }
</style>
<style>
  .cancelled {
     border-bottom: 1px solid red;
     border-right: 10px solid red;
  }
  .inprogress {
     border-bottom: 1px solid #ffb700;
     border-right: 10px solid #ffb700;
  }
  .accepted {
     border-bottom: 1px solid #038a1e;
     border-right: 10px solid #038a1e;
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
	<!--  accept order modal start -->
	<div class="modal fade" id="acceptOrderModal" tabindex="-1"
		aria-labelledby="acceptOrderModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="exampleModalLabel">Accept Order</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
				  
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-outline-danger"
						data-bs-dismiss="modal">Close</button>
					<button type="button" class="btn btn-success">Accept order</button>
				</div>
			</div>
		</div>
	</div>
	<!--  accept order modal end  -->
	<div class="container-fluid" style="margin-top: 40px;">
	  <h4>Your received orders,</h4>
	  <div class="row m-5" style="margin-top: 40px;">
	    <%
	       if(partnerOrders.size()==0) {
	    %>
	        <h5 style="margin-top: 250px; margin-left: 300px;">You haven't received any orders yet</h5>
	    <%
	       }
	    %>
	    <%
	       for(HashMap<String, Object> partnerOrder:partnerOrders) {
	    	   int orderId = (Integer) partnerOrder.get("order_id");
	    	   String serviceImageURL = partnerOrder.get("service_image")==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : (String) partnerOrder.get("service_image");
	           String orderStatus = partnerOrder.get("order_status").equals("accepted by partner") ? "accepted" : ((String)partnerOrder.get("order_status")).contains("cancelled") ? "cancelled" : "inprogress";
	    %>
	    <div class="col-6">
	       <div class="card m-3 shadow-lg p-1 mb-4 bg-body rounded <%= orderStatus %>">
	          <div class="row m-3">
	            <div class="col-6"><img src="<%= serviceImageURL %>" width="75px;" height="75px;" /></div>
	            <div class="col-6"><h5><%= partnerOrder.get("customer_name") %></h5><p><%= partnerOrder.get("customer_phno") %>, &nbsp; &nbsp; <b>#<%= partnerOrder.get("order_id") %></b></p></div>
	          </div>
	          <div class="row m-3">
	            <div class="col-6"><b>Service Name: &nbsp; </b><%= partnerOrder.get("service_name") %></div>
	            <div class="col-6"><b>Service Location: &nbsp; </b><%= partnerOrder.get("service_location") %></div>
	          </div>
	          <div class="row m-3">
	            <div class="col-6"><b>Order Value: </b>&nbsp; <%= partnerOrder.get("order_value") %></div>
	            <div class="col-6"><b>Order Received: </b>&nbsp; <%= partnerOrder.get("order_created") %></div>
	          </div>
	          <% 
	             if(partnerOrder.get("order_status").equals("created")) {
	          %>
	          <div class="row m-3">
	            <div class="col-6 d-grid gap-0"><button class="btn btn-success m-0" onclick="acceptOrder(<%= orderId %>, <%= partnerOrder.get("customer_id") %>, <%= partnerOrder.get("order_total_charges") %>, <%= partnerOrder.get("partner_id") %>)" >Accept Order</button></div>
	            <div class="col-6 d-grid gap-0"><button class="btn btn-danger m-0" onclick="cancelOrder(<%= orderId %>, <%= partnerOrder.get("customer_id") %>, <%= partnerOrder.get("order_total_charges") %>, <%= partnerOrder.get("partner_id") %>)">Cancel Order</button></div>
	          </div>
	          <%
	             } else if(partnerOrder.get("order_status").equals("accepted by partner")) { 
	            	 HashMap<String, Object> orderReview = PartnerRepository.getOrderReview((Integer)partnerOrder.get("order_id")); 
		        	 if(orderReview.isEmpty())
		        	 {
	          %>
	          <div class="row m-3">
	            <div class="col-6"><b>Rating: &nbsp; </b>N/A</div>
	            <div class="col-6"><b>Review: &nbsp; </b>N/A</div>
	          </div>
		      <%
		        	 } 
		        	 else  {
		        		  int rating = (Integer) orderReview.get("rating");
		                  String review = (String) orderReview.get("review");  
		      %>
		      <div class="row m-3">
	             <div class="col-6"><b>Rating: &nbsp; </b>
	                <% for(int i=0;i<rating;i++) { %> &#9733; <% } %>
	                <% for(int i=rating;i<5;i++) { %> &#9734; <% } %>
	             </div>
	             <div class="col-6"><b>Review: &nbsp; </b><%= review %></div>
	          </div>
		      <%
		        	 }
		      %>
	          <%
	             } else {
	          %>
	          <div class="row m-3">
	            <div class="col-6"><b>Rating: &nbsp; </b>Order Cancelled</div>
	            <div class="col-6"><b>Review: &nbsp; </b>Order Cancelled</div>
	          </div>
	          <%
	             }
	          %>
	       </div>
	    </div>
       <%
	       }
	       if(((boolean)request.getAttribute("reachedMaxRecords"))==false) {
       %>
         <div class="row">
             <button class="btn btn-outline-primary" id="loadMoreButton" style="width: 200px; margin-left: 600px; margin-top: 30px;"> Load More </button>
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

if(sessionStorage.getItem("scrollToY")!=null)
{
	let scrollToY = parseFloat(sessionStorage.getItem("scrollToY"));
	window.scrollTo(0, scrollToY);
	sessionStorage.setItem("scrollToY", null);
}

document.getElementById("loadMoreButton").addEventListener("click",function(event){

	event.preventDefault();
	let currentLocation = window.scrollY;
	currentLocation += 250;
	sessionStorage.setItem("scrollToY", currentLocation+"");
	let params = new URL(location);
	let searchParams = params.searchParams;
	let currentLimit = parseInt(searchParams.get("limit"));
	if(isNaN(currentLimit))
	{
		location.replace("/zylkerservices/index.jsp");
	}
	else
	{
		searchParams.set("limit", currentLimit+8);
		params.search = searchParams.toString();
		location.replace(params.toString());
	}	
});

function confirmOrder(orderId, customerId, orderValue, partnerId)
{
	let orderSelectedForAccepting = orderId;
	let origin = location.origin;
	let path = "/zylkerservices/account/orders?action=accept_order";
	xhr.open("POST",(origin+path));
	let data = {
		"csrf": document.getElementById("csrf").value,
		"order_id": orderId,
		"customer_id": customerId,
		"order_value": orderValue.toFixed(1),
		"partner_id": partnerId
	};
	xhr.send(JSON.stringify(data));
	 xhr.onreadystatechange = function() {
		 if(this.readyState == 4 && this.status==202)
		{
		  location.reload();
		}
	}
}

function rejectOrder(orderId, customerId, orderValue, partnerId)
{
	let orderSelectedForCancellation = orderId;
	let origin = location.origin;
	let path = "/zylkerservices/account/orders?action=cancel_order";
	xhr.open("POST",(origin+path));
	let data = {
		"csrf": document.getElementById("csrf").value,
		"order_id": orderId,
		"customer_id": customerId,
		"order_value": orderValue.toFixed(1),
		"partner_id": partnerId
	};
	xhr.send(JSON.stringify(data));
	 xhr.onreadystatechange = function() {
		 if(this.readyState == 4 && this.status==202)
		{
		  location.reload();
		}
	}
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