<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" errorPage = "serverError.jsp"%>
<%@ page import="com.zylkerservices.SearchService, java.util.List, java.util.HashMap, com.zylkerservices.PartnerRepository" %>
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
<title>My Services</title>
</head>
<body style="background-color: #f2f2f2;">
        <%
              HashMap jwt = (HashMap) request.getAttribute("jwt_verification");
              List<String> availableServices = SearchService.fetchAllAvailableServices();
              List<String> availableLocations = SearchService.fetchAllAvailableLocations();
              List<String> myServices = PartnerRepository.fetchAllMyServices((Integer)jwt.get("user_id"));
              boolean accountCreated = session.getAttribute("name") == null ? false : true;
              if(!accountCreated)
              	response.sendRedirect("/zylkerservices/account?display=account_not_created");
        %>
        <!-- Nav Bar start -->
    	<nav class="navbar sticky-top navbar-light" style="background-color: rgb(4, 4, 92);">
		<div class="container-fluid">
			<div class="row">
				<div class="float-left">
					<a class="navbar-brand text-white" style="margin-left: 20px;" href="/zylkerservices/index.jsp">Zylker Services</a>
				</div>
			</div>
			<div class="row">
				<div class="float-right">
				    <a href="/zylkerservices/account/analytics" class="btn btn-sm text-white" style="margin-right: 25px;">Analytics</a>
					<a href="/zylkerservices/account/myorders?limit=8" class="btn btn-sm text-white" style="margin-right: 25px;">Orders</a>
					<a href="" class="btn btn-sm text-white" style="margin-right: 25px;">Transactions</a>
					<a href="/zylkerservices/account" class="btn btn-sm text-white" style="margin-right: 25px;">My
						Account</a>
					<button onclick="signOut()" class="btn btn-sm text-white" style="margin-right: 5px;">Sign Out</button>
				</div>
			</div>
		</div>
	</nav>
	<!-- Nav bar end -->
	<!-- Add a new service modal start -->
	<div class="modal fade" id="addAServiceModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="addAServiceModalLabel">Add a service</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>
				<div class="modal-body">
				    <select class="form-select" id="serviceName">
						<%
						for (String service : availableServices) {
						%>
						    <option><%=service%></option>
						<%
						}
						%>
					</select>
					<select class="form-select mt-4" id="serviceLocation">
						<%
						for (String location : availableLocations) {
						%>
						    <option><%=location%></option>
						<%
						}
						%>
					</select>
					<input type="number" placeholder="Service charge" id="serviceCharge" class="form-control mt-4"/>
					<input type="file" id="partnerServiceImage" name="partnerServiceImage" class="form-control mt-4" id="serviceImage" />
					<p id="addServiceModalError" style="color:red; margin-top: 20px;"></p>
					<input type="text" name="csrf" id="csrf" value="<%= jwt.get("csrf") %>" contenteditable="false" style="display:none" />
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
					<button type="button" class="btn btn-primary" id="addNewService">Confirm<b id="loading"></b></button>
				</div>
			</div>
		</div>
	</div>
	<!-- Add a new service modal end -->
	<div class="container" style="margin-top: 50px;">
	    <div class="row">
	        <div class="col-4">
	             <h5>Your services,</h5>
	             <button type="button" class="btn btn-primary" style="margin-top: 30px;" data-bs-toggle="modal" data-bs-target="#addAServiceModal">Add a service</button>
	        </div>
	    </div>
	    <div class="row" style="margin-top: 45px">
	      <%
	         if(myServices.size()==0) {
	      %>
	         <h5 style="margin-top: 150px; margin-left: 300px;">You haven't added any services yet</h5>
	      <%
	         } else {
	      %>
	      <table class="table table-striped">
	          <thead>
	             <tr>
	               <th>Service Name</th>
	               <th>Service Location</th>
	               <th>Service Charge</th>
	             </tr>
	          </thead>
	          <tbody>
	        <%
	            for(String service:myServices)
	            {
	            	String[] record = service.split("-");
	            	
	        %>
	              <tr>
	                 <th><%= record[0] %></th>
	                 <th><%= record[1] %></th>
	                 <th>Rs. <%= record[2] %>/-</th>
	              </tr>
	        <%
	            }
	        %>
	          </tbody>
	      </table>
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

function isValidServiceCharge()
{
	let serviceCharge = Number(document.getElementById("serviceCharge").value);
	return serviceCharge>=1 && serviceCharge<=10000;
}

document.getElementById("addNewService").addEventListener("click",async function(){
	
	if(isValidServiceCharge())
	{
		if(typeof(partnerServiceImage.files[0])=="object")
		{			
			document.getElementById("loading").innerHTML = '<img src="https://ik.imagekit.io/lgqbj7lz15u/Rolling-1s-200px_NTllp7DPH.svg?ik-sdk-version=javascript-1.4.3&updatedAt=1647514281912" width="22px" height="22px" style="margin-left: 4px; margin-bottom: 2px;" />';
		    let formData = new FormData();
		    formData.append("file", partnerServiceImage.files[0]);
		    formData.append("upload_preset","nnv1oijf"); 
		    let imageXHR = new XMLHttpRequest(); 
		    imageXHR.open("POST", "https://api.cloudinary.com/v1_1/zylkerservices/image/upload");
		    imageXHR.send(formData);
		    imageXHR.onreadystatechange = function() 
		    {
			    if(this.readyState==4 && this.status==200)
			    {
				    let imageUploadResponse = JSON.parse(imageXHR.responseText);
				    let origin = location.origin;
				    let path = "/zylkerservices/account?update=partner_add_new_service";
				    let data = {
						    "service_name": document.getElementById("serviceName").value,
						    "service_charge": document.getElementById("serviceCharge").value,
						    "service_location": document.getElementById("serviceLocation").value,
						    "service_image": imageUploadResponse.url,
						    "csrf": document.getElementById("csrf").value
				    };
				    xhr.open("POST",(origin+path));
				    xhr.setRequestHeader("content-type","application/json");
				    xhr.send(JSON.stringify(data));
				    xhr.onreadystatechange = function() 
				    {
					    if(xhr.readyState == 4 && xhr.status == 200)
					    {
						    location.reload();
					    } 
				    }
			    }
		   }
		} 
		else
		{
			document.getElementById("addServiceModalError").innerText = "Please upload a image to describe your service";
			setTimeout(function(){
				document.getElementById("addServiceModalError").innerText = "";
			}, 6000);
		}
	} 
	else 
	{
		document.getElementById("addServiceModalError").innerText = "Service charge should be more than 1 and less than 10,000 INR";
		setTimeout(function(){
			document.getElementById("addServiceModalError").innerText = "";
		}, 6000);
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