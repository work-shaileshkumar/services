<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="serverError.jsp" %>
  <!doctype html>
 <%@ page import="com.zylkerservices.SearchService,com.zylkerservices.UserRepository, java.util.List, java.util.HashMap, com.zylkerservices.AccountService" %>
  <html lang="en">

  <head>
    <!-- Required meta tags -->
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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js" ></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css" ></link>
    <title>zylker services</title>       
    <style>
#loginButton {
	background-color: rgb(4, 4, 92);
	color: white;
}

.toast {
	margin-top: 50px !important;
}
</style>
  </head>

  <body style="background-color: #e0dcdc"> 

          <%
                HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
                List<String> availableServices = SearchService.fetchAllAvailableServices();
                List<String> availableLocations = SearchService.fetchAllAvailableLocations();
                int customersCount = AccountService.getTotalCustomersCount();
                int partnersCount = AccountService.getTotalPartnersCount();
          		boolean signedIn = false;
          		Cookie[] cookies = request.getCookies();
          		String signedInUserRole = "";
          		String url = (String) session.getAttribute("dp_url");
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
                if(signedIn && jwt!=null)
                {
                	if(!jwt.get("user_role").equals("admin"))
                	{
                        if(!accountCreated)
                	        response.sendRedirect("/zylkerservices/account?display=account_not_created");
                	}
                }
          %>
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
    <!-- Modal -->
    <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="loginModalLabel">Sign In</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form class="is-invalid"> 
              <div class="container">
                <div class="row">
                  <div class="col-4">Email</div>
                  <div class="col-8">
                    <input type="email" id="email" placeholder="email" class="form-control" />
                    <div class="invalid-feedback">Opps! You have entered an invalid email-id</div>
                  </div>
                </div>
                <div class="row" style="margin-top: 20px;">
                  <div class="col-4">Password</div>
                  <div class="col-8">
                    <input type="password" id="password" placeholder="password" class="form-control" />
                    <div class="invalid-feedback">Opps! You have entered a wrong password.</div>
                  </div>
                </div>
                <p id="loginModalError" style="color: red; margin-top: 15px; font-size: 14px;"></p>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <a href="signup.jsp" style="text-decoration: none; margin-right: 90px;">click here
              to signup</a>
            <div id="googleSignInButton">
              <div class="g-signin2" data-onsuccess="onSignIn"></div>
            </div>
                <button class="btn" style="margin-left: 20px;" id="loginButton">Sign In</button>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal end -->
    <div class="container-fluid">
        <div class="row" style="margin-top: 100px">
          <h5 class="text-center" style="margin-bottom: 70px;">Fast, Free, Secure way to find experts in your locality.</h5>
          <div class="col-1 offset-4">
            <div style="margin-left:-35px;">
                <select class="form-select" id="serviceLocation">
                    <option selected disabled><b>City</b></option>
                    <%
                    for(String location:availableLocations)
                    {
                    %>
                    <option><%= location %></option>
                    <%
                    }
                    %>
                </select> 
            </div>
          </div>
          <div class="col-3">
              <select class="form-select" id="serviceName">
                  <option selected disabled>Select a service from dropdown</option>
                  <%
                  for(String service:availableServices)
                  {
                  %>
                  <option><%= service %></option>
                  <%
                  }
                  %>
              </select> 
          </div>
          <div class="col-2">
              <button class="btn btn-primary" id="searchButton" >Get Experts</button> 
          </div>
        </div>
        <div class="row" style="margin-top: 280px;">
			<!--  -->
			   <!-- <h5 style="margin-bottom: 200px; margin-top: 100px;" class="text-center" >South India's Largest platform to find the right partner at Zero Cost</h5> -->
				<div class="col-2" style="margin-left: 300px;">
					<h4><%=customersCount%>+ <img src="https://ik.imagekit.io/lgqbj7lz15u/outline_emoji_emotions_black_24dp_NcLFhHvfh.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648446457302" width="30px;" height="30px;" style="margin-left: 10px;" />
					</h4>
					<h5>
						<b>Happy customers</b>
					</h5>
				</div>
				<div class="col-2" style="margin-left: 150px;">
					<h4><%=partnersCount%>+ <img src="https://ik.imagekit.io/lgqbj7lz15u/outline_verified_black_24dp_yfK-sz-xH.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648446687490" width="30px;" height="30px;" style="margin-left: 10px;" />
					</h4>
					<h5>
						<b>Verified Partners</b>
					</h5>
				</div>
				<div class="col-2" style="margin-left: 150px;">
					<h4>6+<img src="https://ik.imagekit.io/lgqbj7lz15u/outline_design_services_black_24dp_YhAguIRy4.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648446837702" width="30px;" height="30px;" style="margin-left: 10px;" />
					</h4>
					<h5><b>Categories</b></h5>
				</div>

		</div>
    </div>
    <div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
  </body>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>
  
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
	    if (this.readyState == 4) {
	      if (this.status == 200) {
	    	  if(xhr.responseText == "")
	    	  {
	    		  location.reload();
	    	  }
	    	  else
	    	  {	  
	    		  let signinResponse = "";
	    		  try{ signinResponse = JSON.parse(xhr.responseText).isSignedIn; }catch(e){}
	    	      if(signinResponse == "noSuchUser") 
	    	      {
	    	    	  document.getElementById("email").classList.remove("is-invalid");
	    	    	  document.getElementById("password").classList.remove("is-invalid");
	    		      document.getElementById("email").classList.add("is-invalid");
	    	      }
	    	      else if(signinResponse == "wrongCredentials")
	              {
	    	    	  document.getElementById("email").classList.remove("is-invalid");
	    	    	  document.getElementById("password").classList.remove("is-invalid");
	    		      document.getElementById("password").classList.add("is-invalid");
	              }	
	    	      else
	    	      {
	                  location.reload();
	    	      }
	    	  }
	      } else if (this.status == 401) {
	        let errorMessage = "No such account or email-id password mismatch";
	        document.getElementById("loginModalError").innerHTML = errorMessage;
	        setTimeout(function () {
	            document.getElementById("loginModalError").innerHTML = "";
	          }, 2500);
	      } else {
	        location.replace("serverError.jsp");
	      }
	    }
	  }
  document.getElementById("loginButton").addEventListener("click",
    function (event) {
      event.preventDefault();
      let data = {
        "email": document.getElementById("email").value,
        "password": document.getElementById("password").value,
        "user_auth_type": "email"
      }
      let email = document.getElementById("email").value;
      let password = document.getElementById("password").value;
      let origin = location.origin;
      let path = "/zylkerservices/user?service=signin";
      xhr.open("POST", (origin + path));
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify(data));
    });

    document.getElementById("searchButton").addEventListener("click",function(event){
      event.preventDefault();
      let service = document.getElementById("serviceName").value;
      let serviceLocation = document.getElementById("serviceLocation").value;
      if(serviceLocation == "City" && service == "Select a service from dropdown")
      {
    	  toastr.error("City and Service from the dropdown", "Please select");
      }	  
      else if(serviceLocation == "City")
      {
    	  toastr.error("Your City", "Please select");
      }	  
      else if(service == "Select a service from dropdown")
      {
    	  toastr.error("The service you are looking for", "Please select");
      }
      else if(serviceLocation != "City" && service != "Select a service from dropdown")
      {
          location.replace("/zylkerservices/search?serviceName="+service+"&serviceLocation="+serviceLocation);  
      }
    });
    
  function onSignIn(googleUser) {
    if (!document.cookie.includes("Z_AUTHUSER")) {
      var profile = googleUser.getBasicProfile();
      let data = {
        "email": profile.getEmail(),
        "user_auth_type": "google"
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
  }

  
</script>
<script>
    $(window).on("load",function(){
       $(".loader-wrapper").fadeOut("slow"); 
    });
</script>
</html>