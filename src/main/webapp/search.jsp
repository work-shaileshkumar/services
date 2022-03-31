<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.zylkerservices.Partner, java.util.HashMap, com.zylkerservices.UserRepository" %>
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
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
      <link rel="stylesheet" href="/zylkerservices/loader.css">
    <script src="https://apis.google.com/js/platform.js" async defer></script>
<title>Zylker Search Results</title>
<style>
  #loginButton {
     background-color: rgb(4, 4, 92);
     color: white;
 }
 #viewPartnerButton {
     background-color: rgb(7, 7, 171);
     color: white;
 }
  #applyFilterButton{
      background-color: rgb(7, 7, 171);
      color: white;
      width: 140px;
  }
 .card, .form-select, .form-control {
     border: 1px solid black;
 }
</style>
</head>
<body style="background-color: #f2f2f2;">
    <%
          List<Partner> relevantPartners = (List<Partner>)request.getAttribute("search_results");
          HashMap jwt = (HashMap) UserRepository.fetchJWT(request);
          boolean signedIn = false;
          Cookie[] cookies = request.getCookies();
          String signedInUserRole = "";
          if(cookies != null)
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
    <!-- Nav Bar Start -->
        <nav class="navbar sticky-top navbar-light" style="background-color: rgb(4, 4, 92);">
      <div class="container-fluid">
        <div class="row">
          <div class="float-left">
            <a class="navbar-brand text-white" style="margin-left: 20px;" href="index.jsp">Zylker Services</a>
          </div>
        </div>
        <div class="row">
          <div class="float-right">
			 <%
                if(!signedIn)
                {
             %>
             <a href="signup.jsp" type="button" class="btn btn-primary btn-sm"
              style="margin-right: 20px; border-radius: 60px; background-color: rgb(4, 4, 92);">
              Sign Up
            </a>
            <button type="button" class="btn btn-primary btn-sm"
              style="margin-right: 20px; border-radius: 60px; background-color: rgb(4, 4, 92);" data-bs-toggle="modal"
              data-bs-target="#loginModal">Sign In
            </button>
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
    <!-- Nav Bar End -->
    <!-- Modal start -->
	<div class="modal fade" id="loginModal" tabindex="-1"
		aria-labelledby="loginModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="loginModalLabel">Sign In</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
					<div class="container">
						<div class="row">
							<div class="col-4">Email</div>
							<div class="col-8">
								<input type="email" id="email" placeholder="email"
									class="form-control" />
							</div>
						</div>
						<div class="row" style="margin-top: 20px;">
							<div class="col-4">Password</div>
							<div class="col-8">
								<input type="password" id="password" placeholder="password"
									class="form-control" />
							</div>
						</div>
						<p id="loginModalError"
							style="color: red; margin-top: 15px; font-size: 14px;"></p>
					</div>
				</div>
				<div class="modal-footer">
					<a href="signup.jsp"
						style="text-decoration: none; margin-right: 90px;">click here
						to signup</a>
					<div id="googleSignInButton">
						<div class="g-signin2" data-onsuccess="onSignIn"></div>
					</div>
					<button class="btn" style="margin-left: 20px;" id="loginButton">Sign
						In</button>
				</div>
			</div>
		</div>
	</div>
	<!-- Modal end -->
    <div class="container">
        <div class="row">
            <div class="col-2">
                 <!-- sort and filter box -->
            </div>
            <div class="col-10">
                 <!-- Search Result Data -->
                 <div class="container">
                     <div class="row">
						<h5 class="m-4">Found <%=relevantPartners.size()%> Partners for "<%=request.getParameter("serviceName")%>" in <%=request.getParameter("serviceLocation")%></h5>	
						<%
						   if(relevantPartners.size() > 0) { 
						%>
						<div class="row" style="margin-top: 20px; margin-bottom: 20px;">
							<div class="col-3" style="margin-left: 30px;">
								<select class="form-select" id="sortType">
									<option <%= request.getParameter("sortType")!=null && request.getParameter("sortType").equals("Relevance") ? "selected" : "" %>>Relevance</option>
									<option <%= request.getParameter("sortType")!=null && request.getParameter("sortType").equals("Price Low to High") ? "selected" : "" %>>Price Low to High</option>
									<option <%= request.getParameter("sortType")!=null && request.getParameter("sortType").equals("Price High to Low") ? "selected" : "" %>>Price High to Low</option>
									<option <%= request.getParameter("sortType")!=null && request.getParameter("sortType").equals("Rating Low to High") ? "selected" : "" %>>Rating Low to High</option>
									<option <%= request.getParameter("sortType")!=null && request.getParameter("sortType").equals("Rating High to Low") ? "selected" : "" %>>Rating High to Low</option>
								</select>
							</div>
							<div class="col-4 offset-1">
							    <input type="text" name="csrf" value="<%= jwt==null ? "" : jwt.get("csrf") %>" id="csrf" style="display:none" contenteditable="false" />
							    <input type="text" placeholder="Search by partner name" id="searchText" value="<%= request.getParameter("searchTxt")==null ? "" : request.getParameter("searchTxt") %>" class="form-control"/>
							</div>
							<div class="col-2 offset-0">
							    <button class="btn" id="applyFilterButton">Apply Filter</button>
							</div> 
						</div>			   
                         <%
						   }
					           if (relevantPartners.size() == 0) {
					                out.println("<h3 style=\"margin-top: 200px; margin-left: 400px;\">No Results Found</h3>");
					           }
					           for (Partner partner : relevantPartners) {
					        	   String partnerDpURL = partner.getPartner_dp_url()==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : partner.getPartner_dp_url();
					               int rating = (int) partner.getAvg_rating();
					     %>
						<div class="col-6">
							<div class="card m-4 shadow-lg p-3 mb-5 bg-body rounded">
								<div class="card-body">
									<div class="row">
									  <div class="col-6"><h5 class="card-title"><%=partner.getPartner_name()%></h5></div>
									  <div class="col-6"><img src = "<%= partnerDpURL %>" height="75px;" width="75px;" style="margin-left: 95px; margin-top: 20px; border-radius: 10px;" /></div>
									</div>
									<p class="card-text">
										Phno:
										<%=partner.getPartner_phno()%></p>
									<p class="card-text">
										Rating: &nbsp;
										<%for(int i=0;i<rating;i++) {%>&#9733;<% }%>
										<%for(int i=rating;i<5;i++) {%>&#9734;<% }%>
									</p>
									<div class="row">
									    <%
									      String hrefLink = signedIn ? "/zylkerservices/search/partner?action=viewPartnerProfile&partnerId="+partner.getPartner_id()+"&serviceName="+request.getParameter("serviceName")+"&serviceLocation="+request.getParameter("serviceLocation") : "";                     
									    %>
									    <a href="<%= hrefLink %>" <%= !signedIn ? "data-bs-toggle='modal' data-bs-target='#loginModal'" : "" %>  role="button" target="_blank" id="viewPartnerButton" class="btn btn-sm col-3 offset-0 m-2">View More</a>
									    <h4" class="col-3 offset-5 mt-2"><b>Rs. <%= partner.getService_charge() %>/-</b></h4>
									</div> 
								</div>
							</div>
						</div>
						<%
                           }
                        %>
                     </div>
                 </div>
            </div>
        </div>
    </div>
    <div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous">
  </script>
<script>

	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if (this.readyState == 4) {

			if (this.status == 200) {
				location.reload();
			} else if (this.status == 401) {
				let errorMessage = "No such account or email-id password mismatch";
				document.getElementById("loginModalError").innerHTML = errorMessage;
				setTimeout(function() {
					document.getElementById("loginModalError").innerHTML = "";
				}, 2500);
			} else {
				location.replace("serverError.jsp");
			}
		}
	}
    document.getElementById("applyFilterButton").addEventListener("click",function(){
    	let params = (new URL(location)).searchParams;
        let service = params.get("serviceName");
        let serviceLocation = params.get("serviceLocation");
        let searchText = document.getElementById("searchText").value;
        let sortType = document.getElementById("sortType").value;
        location.replace("/zylkerservices/search?serviceName="+service+"&serviceLocation="+serviceLocation+"&searchTxt="+searchText+"&sortType="+sortType);
      });
	document.getElementById("loginButton").addEventListener("click",
			function(event) {
				event.preventDefault();
				let data = {
					"email" : document.getElementById("email").value,
					"password" : document.getElementById("password").value,
					"user_auth_type" : "email"
				}
				let email = document.getElementById("email").value;
				let password = document.getElementById("password").value;
				let origin = location.origin;
				let path = "/zylkerservices/user?service=signin";
				xhr.open("POST", (origin + path));
				xhr.setRequestHeader('Content-Type', 'application/json');
				xhr.send(JSON.stringify(data));
			});


	function onSignIn(googleUser) {
		if (!document.cookie.includes("Z_AUTHUSER")) {
			var profile = googleUser.getBasicProfile();
			let data = {
				"email" : profile.getEmail(),
				"user_auth_type" : "google"
			}
			let origin = location.origin;
			let path = "/zylkerservices/user?service=signin";
			xhr.open("POST", (origin + path));
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify(data));
		}
	}

	function signOut() {
		let cookie = document.cookie;
		let auth_type = cookie.substring(cookie.indexOf("Z_AUTHUSER="))[11];
		if (auth_type == 'G') {
			var auth2 = gapi.auth2.getAuthInstance();
			auth2.signOut().then(function() {

			});
		}
		let origin = location.origin;
		let path = "/zylkerservices/user?service=signout&csrf="+document.getElementById("csrf").value;
		xhr.open("POST", (origin + path));
		xhr.send();
	}
	    
</script>
<script>
     $(window).on("load",function(){
        $(".loader-wrapper").fadeOut("slow");
    });
</script>
</html>

