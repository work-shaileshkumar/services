<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="serverError.jsp" %>
<%@ page import="com.zylkerservices.Customer, java.util.HashMap" %>
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
	<title>zylker account</title>
	<style>
		input {
			border: none;
			border-bottom: 2px solid black;
			background-color: #f2f2f2;
		}

		input:focus {
			outline: none;
		}
	</style>
</head>

<body style="background-color: #f2f2f2;">
    <% 
         Customer customer = (Customer) request.getAttribute("customer_data");
         HashMap jwt = (HashMap) request.getAttribute("jwt_verification");
         String customerDpURL = customer.getCustomer_dp_url()==null ? "https://ik.imagekit.io/lgqbj7lz15u/noimage_mkUvVkY-Q.png?ik-sdk-version=javascript-1.4.3&updatedAt=1648031069478" : customer.getCustomer_dp_url();
         if(jwt==null)
        	 response.sendRedirect("index.jsp");
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
					<a href="/zylkerservices/account/myorders" class="btn btn-sm text-white" style="margin-right: 25px;">My Orders</a>
					<a href="/zylkerservices/account/favourites"  class="btn btn-sm text-white" style="margin-right: 25px;">Favourites</a>
					<a href="/zylkerservices/account/wallet" class="btn btn-sm text-white" style="margin-right: 25px;">Wallet</a>
					<a href="/zylkerservices/account" class="btn btn-sm text-white" style="margin-right: 25px;">My
						Account</a>
					<button onclick="signOut()" class="btn btn-sm text-white" style="margin-right: 5px;">Sign Out</button>
				</div>
			</div>
		</div>
	</nav>
	<!-- update dp modal start -->
	<div class="modal fade" id="dpModal" tabindex="-1" aria-labelledby="dpModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="dpModalLabel">Update your profile picture</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
				  <input type="file" class="form-control" id="userDpImage" name="userDpImage" />
				</div>
				<p style="color: red; margin-top: 20px; margin-left: 20px;" id="updateDpModalError"></p>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Cancel</button>
					<button type="button" id="updateDp" class="btn btn-primary">Update<b id="imageLoading"></b></button>
				</div>
			</div>
		</div>
	</div>
	<!-- update dp modal end -->
	<!-- display modal start-->
	<div class="modal fade" id="displayModal" tabindex="-1"
		aria-labelledby="displayModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="displayModalLabel">Please complete your account first</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>
				<div class="modal-body">
				  <h6><b>To continue using our services please complete your account now, To complete your account</b></h6>
				  <ol>
				    <li>Click on edit profile,</li>
				    <li>And then enter your name, and phno</li>
				    <li>Click on the save changes button.</li>
				  </ol>
				  <p>You need to complete these steps to continue using your account</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-primary" data-bs-dismiss="modal">I understood</button>
				</div>
			</div>
		</div>
	</div>
	<!-- display modal end -->
	<div class="container-fluid">
		<div class="row" style="margin-bottom: 20px; margin-top: 20px;">
		   <div class="text-center">
		     <img src="<%= customerDpURL %>" onclick="javascript: updateProfile();" width="200px;" height="200px;" style="border-radius: 100px" />
		   </div>
		</div>
		<div class="row">
			<nav class="navbar navbar-light" style="background-color: rgb(245, 245, 245);">
				<div class="row">
					<div class="float-right">
						<button type="button" id="editButton" class="btn" style="margin-left: 75px;">Edit
							Profile</button>
						<button type="button" id="saveButton" class="btn" style="margin-left: 100px;">Save Changes</button>
					</div>
				</div>
			</nav>
		</div>
		<div class="row" style="margin-top: 30px;">
		<p class="text-center" id="updateProfileStatus" ></p>
			<div class="col-1"></div>
							
			<div class="col-4">
				<h5 style="margin-bottom: 50px;">Profile Info</h5>
				<input type="text" name="csrf" value="<%= jwt.get("csrf") %>" id="csrf" style="display:none" contenteditable="false" />  
				Name: <input type="text" id="customer_name" value="<%= customer.getCustomer_name()==null ? "" : customer.getCustomer_name() %>" style="margin-left: 70px;" placeholder="Enter your name" />
				<br />
				Phno: <input type="number" id="customer_phno" value="<%= customer.getCustomer_phno()==null ? "" : customer.getCustomer_phno() %>" style="margin-top: 35px; margin-left: 70px;"
					placeholder="Enter your phno" /> <br />
				Email-id: <input type="wallet_balance" id="customer_email" value="<%= customer.getCustomer_email()==null ? "" : customer.getCustomer_email() %>"
					style="margin-top: 35px; margin-left: 50px;" /><br />
			</div>
			<div class="col-1"></div>
			<div class="col-4">
				<h5 style="margin-bottom: 50px;">Reset Password</h5>
				Current Password: <input type="password" id="currentPassword" value="" style="margin-left: 90px;"
					placeholder="current password" /> <br />
				New Password: <input type="password" id="newPassword" style="margin-left: 110px; margin-top: 35px;" value=""
					placeholder="new password" /> <br />
				Re-enter New Password: <input type="password" id="reNewPassword" value=""
					style="margin-left: 40px; margin-top: 35px;" placeholder="re-enter new password" /> <br />
				<button id="resetPasswordButton" class="btn btn-sm btn-danger" style="margin-top: 30px;" >Reset Password</button>
			</div>
		</div>
	</div>
	<div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<script>

	window.onload = function () {
		document.getElementById("customer_name").disabled = true;
		document.getElementById("customer_phno").disabled = true;
		document.getElementById("customer_email").disabled = true;
		document.getElementById("saveButton").disabled = true;
		let params = new URL(location).searchParams;
		if(params.get("display") != null)
		{
			$("#displayModal").modal("toggle");
		}
	}

	document.getElementById("editButton").addEventListener("click", function () {
		document.getElementById("customer_name").disabled = false;
		document.getElementById("customer_phno").disabled = false;
		document.getElementById("saveButton").disabled = false;
	});
	
    function updateProfile()
    {
    	$("#dpModal").modal("toggle");
    }
    
    function isValidPhno()
    {
    	let phno = document.getElementById("customer_phno").value;
    	if(phno.length == 10)
    	{
    		return true;
    	}
    	else
    	{
    		return false;
    	}
    }
    
    function isValidName()
    {
    	let name = document.getElementById("customer_name").value;
    	if(name.length >= 3)
        {
    		return true;
        }
    	else
    	{
    		return false;
    	}
    }
	
    document.getElementById("updateDp").addEventListener("click",function(){
    	
    	if(typeof(userDpImage.files[0]) == "object")
    	{
    	    let xhr = new XMLHttpRequest();
    	    document.getElementById("imageLoading").innerHTML = '<img src="https://ik.imagekit.io/lgqbj7lz15u/Rolling-1s-200px_NTllp7DPH.svg?ik-sdk-version=javascript-1.4.3&updatedAt=1647514281912" width="22px" height="22px" style="margin-left: 4px; margin-bottom: 2px;" />';
    	    let formData = new FormData();
    	    formData.append("file", userDpImage.files[0]);
    	    formData.append("upload_preset","nnv1oijf"); 
    	    xhr.open("POST", "https://api.cloudinary.com/v1_1/zylkerservices/image/upload");
    	    xhr.send(formData);
    	    xhr.onreadystatechange = function() {
    		    if(this.readyState == 4 && this.status == 200)
    		    {
    		        let imageUploadResponse = JSON.parse(xhr.responseText);
    		        let imageXHR = new XMLHttpRequest();
        	        let origin = location.origin;
        	        let path = "/zylkerservices/account?update=update_dp";
    		        imageXHR.open("POST", (origin+path));
        	        let data = {
            	        "csrf": document.getElementById("csrf").value,
            	        "url": imageUploadResponse.url
                    };
        	        imageXHR.send(JSON.stringify(data));
        	        imageXHR.onreadystatechange = function() {
        	         if(imageXHR.readyState == 4 && imageXHR.status == 202)
        	         {
            	         location.reload();	
        	         }
        	        }
    		    } 
    		    else if(this.readyState == 4 && this.status != 200)
    		    {
    			    $("#displayModal").modal("toggle");
    		    }
    	    }
    	}
    	else
    	{
    		document.getElementById("updateDpModalError").innerText = "Please select a image and click on update button";
    		setTimeout(function(){
    			document.getElementById("updateDpModalError").innerText = "";
    		}, 4000);
    	}
    });
    
	
	document.getElementById("saveButton").addEventListener("click", function () {
		
		if(isValidName())
	    {
			if(isValidPhno())
			{
				let data = {
						"customer_name": document.getElementById("customer_name").value,
						"customer_phno": document.getElementById("customer_phno").value,
						"csrf": document.getElementById("csrf").value
					}
					let xhr = new XMLHttpRequest();
					let origin = location.origin;
			        let path = "/zylkerservices/account?update=customer_profile_info";
			        xhr.open("POST", (origin + path));
					xhr.setRequestHeader('Content-Type', 'application/json');
					xhr.send(JSON.stringify(data));
					xhr.onreadystatechange = function() {
						if(this.readyState == 4)
						{
							if(this.status == 200)
							{
							    document.getElementById("saveButton").disabled = true;
							    document.getElementById("customer_name").disabled = true;
							    document.getElementById("customer_phno").disabled = true;
								document.getElementById("updateProfileStatus").style.color = "green";
								document.getElementById("updateProfileStatus").innerHTML = "Your profile has been updated successfully";
								setTimeout(function(){
									document.getElementById("updateProfileStatus").style.color = "black";
									document.getElementById("updateProfileStatus").innerHTML = "";
									location.replace("/zylkerservices/account");
								},1000);
							}
							else
							{
								document.getElementById("updateProfileStatus").style.color = "red";
								document.getElementById("updateProfileStatus").innerHTML = "Changes Not Saved ! Something is wrong in our end";
								setTimeout(function(){
									document.getElementById("updateProfileStatus").style.color = "black";
									document.getElementById("updateProfileStatus").innerHTML = "";
								},2500);
							}
						}
					}	
			} else {
				document.getElementById("updateProfileStatus").style.color = "red";
				document.getElementById("updateProfileStatus").innerHTML = "Please provide a valid phone number [ a phone number must be of length 10 ] ";
				setTimeout(function(){
					document.getElementById("updateProfileStatus").style.color = "black";
					document.getElementById("updateProfileStatus").innerHTML = "";
				},6000);
			}
	    }
		else
		{
			document.getElementById("updateProfileStatus").style.color = "red";
			document.getElementById("updateProfileStatus").innerHTML = "Please provide a valid name, your name cannot be empty and must contain atleast 3 characters";
			setTimeout(function(){
				document.getElementById("updateProfileStatus").style.color = "black";
				document.getElementById("updateProfileStatus").innerHTML = "";
			},6000);
		}	
	});
	
	function isSamePasswords()
	{
		let password = document.getElementById("newPassword").value;
		let reEnteredPassword = document.getElementById("reNewPassword").value;
		if(password == reEnteredPassword)
		{
			return true;
		}
		else
		{
			document.getElementById("updateProfileStatus").style.color = "red";
			document.getElementById("updateProfileStatus").innerHTML = "New password and re-entered New passwords are mismatching";
			setTimeout(function(){
				document.getElementById("updateProfileStatus").style.color = "black";
				document.getElementById("updateProfileStatus").innerHTML = "";
			},4500);
			return false;
		}	
	}
	
    function isValidPassword()
    { 
    	let password = document.getElementById("newPassword").value;
    	let pattern = /^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$/;
    	return pattern.test(password);
    }
	
    function findMissingCharsInPassword(password)
    {
    	let errorMsg = [];
    	if(!hasNumberic(password))
    		errorMsg.push("a numeric character [0 - 9]");
    	if(!hasLowerCase(password))
    		errorMsg.push("a lowercase character [a - z]");
    	if(!hasSpecialChars(password))
    		errorMsg.push("a special character Eg [#,@,!,%,...]");
    	if(!hasUpperCase(password))
    		errorMsg.push("a uppercase character [A - Z]");
    	if(password.length < 8)
    	{
    		let req = 8-password.length;
    		let message = req+" more characters to make password length 8";
    		errorMsg.push(message);
    	}
    	return errorMsg;
    }
    
    function hasUpperCase(val)
    {
    	for(ch of val) {
    		if(ch == ch.toUpperCase() && ch>='A' && ch<='Z') 
    		{
    			return true;
    		}
    	}
    	return false;
    }
    
    function hasLowerCase(val)
    {
    	for(ch of val) {
    		if(ch == ch.toLowerCase() && ch>='a' && ch<='z') return true;
    	}
    	return false;
    }
    
    function hasSpecialChars(val)
    {
    	let specialChars = "~!@#$%^&*()_-+{}[]<>?/";
    	for(ch of val) {
    		if(specialChars.includes(ch)) return true;
    	}
    	return false;
    }
    
    function hasNumberic(val)
    {
    	let numericChars = "0123456789";
    	for(ch of val) {
    		if(numericChars.includes(ch)) return true;
    	}
    	return false;
    }
	
	document.getElementById("resetPasswordButton").addEventListener("click",function(){
		
		if(isSamePasswords())
		{
			if(isValidPassword())
			{
				let xhr = new XMLHttpRequest();
				let origin = location.origin;
				let path = "/zylkerservices/account?update=reset_user_password";
				xhr.open("POST",(origin+path));
				let data = {
						"current_password": document.getElementById("currentPassword").value,
						"new_password": document.getElementById("newPassword").value,
						"csrf": document.getElementById("csrf").value
				};
				xhr.onreadystatechange = function(){
					
					let passwordUpdateResponse = JSON.parse(xhr.responseText);
					if(passwordUpdateResponse.passwordChange == "wrongCurrentPassword")
					{
						document.getElementById("updateProfileStatus").style.color = "red";
						document.getElementById("updateProfileStatus").innerHTML = "Your current password is wrong, please try again";
						setTimeout(function(){
							document.getElementById("updateProfileStatus").style.color = "black";
							document.getElementById("updateProfileStatus").innerHTML = "";
						},4000);
					}
					if(passwordUpdateResponse.passwordChange == "success")
					{
						document.getElementById("updateProfileStatus").style.color = "green";
						document.getElementById("updateProfileStatus").innerHTML = "Password change success";
						setTimeout(function(){
							document.getElementById("updateProfileStatus").style.color = "black";
							document.getElementById("updateProfileStatus").innerHTML = "";
							location.reload();
						},2500);
					}
				}
				xhr.send(JSON.stringify(data));
			}
			else
			{
				let password = document.getElementById("newPassword").value;
        		let missingChars = findMissingCharsInPassword(password);
        		let errorMessage = "";
        		for(err of missingChars) {
        			msg = err;
        			errorMessage = err;
        			break;
        		}
        		if(missingChars.length == 5)
        		{
        			document.getElementById("updateProfileStatus").style.color = "red";
            		document.getElementById("updateProfileStatus").innerHTML = "*password cannot be empty";
        		}
        		else
        		{
        			document.getElementById("updateProfileStatus").style.color = "red";
            		document.getElementById("updateProfileStatus").innerHTML = "*Weak new password you still need to add "+errorMessage;
        		}
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
    let xhr = new XMLHttpRequest();
    let origin = location.origin;
    let path = "/zylkerservices/user?service=signout&csrf="+document.getElementById("csrf").value;
    xhr.open("POST", (origin + path));
    xhr.send();
    xhr.onreadystatechange = function() {
    	if(this.readyState == 4 && this.status==200)
    	{
    		location.replace("index.jsp");
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