<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="serverError.jsp" %>
<!doctype html>
<html lang="en">

<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="google-signin-client_id"
        content="401866588161-ia8dho0lbmgppc06er4ccpll0p9lfqt3.apps.googleusercontent.com">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="stylesheet" href="/zylkerservices/loader.css">
    <script src="https://apis.google.com/js/platform.js" async defer></script>
    <title>signup</title>
    <style>
        input {
            border: none;
            border-bottom: solid 2px black;
            background-color: #f2f2f2;
        }

        input:focus {
            outline: none;
        }
    </style>
</head>

<body style="background-color: #f2f2f2;">
    <nav class="navbar sticky-top navbar-light" style="background-color: rgb(4, 4, 92);">
        <div class="container-fluid">
            <div class="row">
                <div class="float-left">
                    <a class="navbar-brand text-white" style="margin-left: 20px;" href="index.jsp">Zylker Services</a>
                </div>
            </div>
            <div class="row">
                <div class="float-right">
                    <a type="button" href="index.jsp" class="btn btn-primary btn-sm"
                        style="margin-right: 20px; border-radius: 60px; background-color: rgb(4, 4, 92);">
                        Back to Home Page
                    </a>
                </div>
            </div>
        </div>
    </nav>
    <div class="container">
        <div class="row">
            <div class="col-3"></div>
            <div class="col-6">
                <div class="container">
                    <div class="row" style="margin-top: 60px;">
                        <div class="text-center">
                            <h3>Create account</h3>
                            <form style="margin-top: 80px;">
                                <input style="display: none" value="xnayqoqjsha" />
                                <div class="container">
                                    <div class="row">
                                        <div class="col-4">
                                            Email-id
                                        </div>
                                        <div class="col-8">
                                            <input type="email" id="email" autocomplete="off" style="background-color: #f2f2f2;" onchange="validateEmail()" placeholder="Enter your email"><p id="emailErrorMessage" style="color: red" ></p></input>
                                        </div>
                                    </div>
                                    <div class="row" style="margin-top: 40px;" id="passwordInputForm">
                                        <div class="col-4">
                                            Password
                                        </div>
                                        <div class="col-8">
                                            <input type="password" autocomplete="off" id="password" onchange="validatePassword()" placeholder="Enter your password"><p id="passwordErrorMessage" style="color: red"></p></input>
                                        </div>
                                    </div>
                                    <div class="row" style="margin-top: 60px;">
                                        <div class="col-4 offset-1">
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="user_role"
                                                    id="customer" value="customer" checked>
                                            </div>
                                        </div>
                                        <div class="col-7">
                                            <label class="form-check-label" for="customer" style="margin-left: -58%;">
                                                I am a Customer
                                            </label>
                                        </div>
                                    </div>
                                    <div class="row" style="margin-top: 15px;">
                                        <div class="col-4 offset-1">
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="user_role"
                                                    id="partner" value="partner">
                                            </div>
                                        </div>
                                        <div class="col-7">
                                            <label class="form-check-label" for="partner" style="margin-left: -37%;">
                                                I want to join as a Partner
                                            </label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <p id="signUpPageError" style="color: red; margin-top: 30px;"></p>
                                    </div>
                                    <div class="row" style="margin-top: 35px; ">
                                        <div class="col-6">
                                            <div id="googleSignInButton">
                                                <div class="g-signin2" data-width="200" style="margin-left: 30px;" data-height="40" data-longtitle="true" data-onsuccess="onSignIn"></div>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <button style="background-color: rgb(4, 4, 92); color: white; width: 200px;" id="signUpButton" class="btn" disabled >Sign Up</button>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-3"></div>
        </div>
    </div>
    <div class="loader-wrapper">
      <span class="loader"><span class="loader-inner"></span></span>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous"></script>
</body>
<script>

    let user_auth_type = "email";
    let email_verification = false;
 
    var xhr = new XMLHttpRequest();
    document.getElementById("signUpButton").addEventListener("click", function (event) {
    	event.preventDefault();
        let origin = location.origin;
        let path = "/zylkerservices/user?service=signup";
        xhr.open("POST",(origin+path));
        console.log(origin+path)
        xhr.setRequestHeader('Content-Type', 'application/json');
        var data = {
            "email": document.getElementById("email").value,
            "password": document.getElementById("password").value,
            "user_role": document.querySelector('input[name="user_role"]:checked').value,
            "user_auth_type": user_auth_type,
            "email_verification": email_verification
        }
        xhr.onreadystatechange = function() 
        {
        	if(this.readyState == 4)
        	{
        		if(this.status == 200)
        		{
        			document.getElementById("signUpPageError").style.color = "green"; 
        		    document.getElementById("signUpPageError").innerHTML = "Account Created Successfully ";
        		    document.getElementById("signUpButton").disabled = true;
        		    document.getElementById("googleSignInButton").style.display = "none";  
        		    setTimeout(function() {
            		    document.getElementById("signUpPageError").innerHTML = "";
            		    document.getElementById("signUpPageError").style.color = "red";
            		    location.replace("/zylkerservices/account?display=account_not_created");
                    },500);
        		}
        		else if(this.status == 400)
        		{
        		    document.getElementById("signUpPageError").innerHTML = "*Either this email-id is already registered / invalid email with a weak password";
        		    setTimeout(function() {
            		    document.getElementById("signUpPageError").innerHTML = "";
                    },2500);
        		}
        		else
        		{
        		    location.replace("serverError.jsp");
        		}
        	}
        };
        xhr.send(JSON.stringify(data));     
    });
	var isValidPassword = false;
	var isValidEmail = false;
    function validateEmail()
    { 
    	let email = document.getElementById("email").value;
    	let pattern = /^([a-zA-z0-9]{1,64})+@+([a-zA-Z0-9]{1,255})+(.)+([a-zA-Z0-9]{1,64})$/;
    	isValidEmail = pattern.test(email);
    	setTimeout(function(){
        	if(!isValidEmail || !email.includes("."))
        	{
        		document.getElementsByTagName("input")[1].style.borderBottom = "2px solid red";
        		document.getElementById("emailErrorMessage").innerText = "*Invalid email";
        	}
        	else
        	{
        		let origin = location.origin;
        		let path = "/zylkerservices/user?service=checkIfIsRegisteredEmail";
        		xhr.open("POST", (origin+path));
        		let data = {
        			"email": email
        		};
        		xhr.send(JSON.stringify(data));
        		xhr.onreadystatechange = function() {
        			if(xhr.readyState == 4 && xhr.status == 200)
        			{
        				let xhrResponse = JSON.parse(xhr.responseText);
        				if(xhrResponse.isExisting)
        				{
        	        		document.getElementsByTagName("input")[1].style.borderBottom = "2px solid red";
        	        		document.getElementById("emailErrorMessage").innerText = "*This email id is already registered, please login";
        	        		document.getElementById("signUpButton").disabled = true;
        				}
        				else
        				{
        	        		document.getElementsByTagName("input")[1].style.borderBottom = "2px solid black";
        	        		document.getElementById("emailErrorMessage").innerText = "";
        				}
        			}
        		}
        	}
        	if(isValidEmail && isValidPassword)
        		document.getElementById("signUpButton").disabled = false;
    	}, 400);
    }
    
    document.getElementById("email").addEventListener("input",function(){
    	validateEmail()
    });
    
    function validatePassword()
    { 
    	let password = document.getElementById("password").value;
    	let pattern = /^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$/;
    	isValidPassword = pattern.test(password);
    	setTimeout(function(){
        	if(!isValidPassword)
        	{
        		let missingChars = findMissingCharsInPassword(password);
        		let errorMessage = "";
        		for(err of missingChars) {
        			msg = err;
        			errorMessage = err;
        			break;
        		}
        		if(missingChars.length == 5)
        		{
            		document.getElementsByTagName("input")[2].style.borderBottom = "2px solid red";
            		document.getElementById("passwordErrorMessage").innerHTML = "*password cannot be empty";
            		document.getElementById("signUpButton").disabled = true;
        		}
        		else
        		{
            		document.getElementsByTagName("input")[2].style.borderBottom = "2px solid red";
            		document.getElementById("passwordErrorMessage").innerHTML = "*Weak password you still need to add "+errorMessage;
            		document.getElementById("signUpButton").disabled = true;
        		}
        	}
        	else
        	{
        		document.getElementsByTagName("input")[2].style.borderBottom = "2px solid black";
        		document.getElementById("passwordErrorMessage").innerText = "";
        	}
        	if(isValidEmail && isValidPassword)
        		document.getElementById("signUpButton").disabled = false;
    	}, 400);
    }
    
    document.getElementById("password").addEventListener("input", function(){
    	validatePassword();
    });
        
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

    function onSignIn(googleUser) {
        var profile = googleUser.getBasicProfile();
        console.log('Email: ' + profile.getEmail());
        document.getElementById("email").value = profile.getEmail();
        document.getElementById("email").disabled = true;
        document.getElementById("password").value = "";
        document.getElementById("password").disabled = true;
        document.getElementById("passwordInputForm").style.display = "none";
        document.getElementById("googleSignInButton").innerHTML = '<div style="margin-top: 8px; cursor: pointer;" onclick="signOut();">Sign out of Google</div>';
        user_auth_type = "google";
        validateEmail();
        email_verification = true;
    }
    
    
    function signOut() {
        var auth2 = gapi.auth2.getAuthInstance();
        auth2.signOut().then(function () {
        	console.log("a")
        	location.reload();
        });
      }
    
</script>
<script>
     $(window).on("load",function(){
        $(".loader-wrapper").fadeOut("slow");
    });
</script>
</html>