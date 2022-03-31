package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.json.JSONObject;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class UserService extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	
	public static void signin(HttpServletRequest request, HttpServletResponse response, User obj)
	{
		try
		{
			String executionResult = UserRepository.authenticate(obj);
			if(executionResult.startsWith("success"))
			{
				int user_id = Integer.parseInt(executionResult.split("-")[1]);
				String user_role = executionResult.split("-")[2];
				createAndSendJWT_Token(request, response, user_id, user_role, obj.getUser_auth_type());
				Logs.addUserLog(user_id, "Signed In");
				HttpSession session = request.getSession();
				if(user_role.equals("customer"))
				{
				    Customer customer = CustomerRepository.getCustomerProfileInfo(user_id);
				    session.setAttribute("name", customer.getCustomer_name()==null ? null : customer.getCustomer_name().split(" ")[0]);
				    session.setAttribute("dp_url", customer.getCustomer_dp_url()==null ? null : customer.getCustomer_dp_url());
				}
				else if(user_role.equals("partner"))
				{ 
					Partner partner = PartnerRepository.getPartnerProfileInfo(user_id);
				    session.setAttribute("name", partner.getPartner_name()==null ? null : partner.getPartner_name().split(" ")[0]);
				    session.setAttribute("dp_url", partner.getPartner_dp_url()==null ? null : partner.getPartner_dp_url());
				}
			}
			else if(executionResult.equals("wrongCredentials") || executionResult.equals("noSuchUser"))
			{
				PrintWriter out = response.getWriter();
				JSONObject jsonResponse = new JSONObject();
				response.setContentType("application/json");
				jsonResponse.put("isSignedIn", executionResult);
				out.print(jsonResponse);
				out.flush();
			}
			else
			{
				response.sendError(500); // serverError
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("UserService.java", "signin", e.toString());
		}
	}
	
	public static void signup(HttpServletRequest request, HttpServletResponse response, User obj)
	{
		try
		{
			String executionResult = UserRepository.createNewUser(obj);
			if(executionResult.startsWith("userCreated"))
			{
				int user_id = Integer.parseInt(executionResult.split("-")[1]);
				String user_role = executionResult.split("-")[2];
				createAndSendJWT_Token(request, response, user_id, user_role, obj.getUser_auth_type());
			}
			else if(executionResult.equals("userExists"))
			{
				response.sendError(400, "You alreay have an account, please login"); // accepted - but user already exist
			}
			else
			{
				response.sendError(500, "Something is wrong in our end ! we will be back soon"); // serverError
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("UserService.java", "signup", e.toString());
		}
	}
	
	public static void signout(HttpServletRequest request, HttpServletResponse response, String csrf) throws IOException
	{
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		HttpSession session = request.getSession();
		session.invalidate(); 
		if(csrf!=null && jwt.get("csrf").equals(csrf))
		{
		    Cookie[] cookies = request.getCookies();
		    if(cookies != null)
		    {
			    for(Cookie cookie:cookies)
			    {
				    /* if(cookie.getName().equals("user_token"))
				    {
					    cookie.setMaxAge(0);
					    cookie.setPath("/");
					    response.addCookie(cookie);
				    }
				    */
				    if(cookie.getName().equals("Z_AUTHUSER") || cookie.getName().equals("user_token"))
				    {
					    cookie.setMaxAge(0);
					    response.addCookie(cookie);
				    }
			    }	
		    }
		    response.sendRedirect("index.jsp");
		}
		else
		{
			response.getWriter().println("bad request");
		}
	}
	
	
	public static void createAndSendJWT_Token(HttpServletRequest request, HttpServletResponse response, int user_id,String user_role, String user_auth_type) throws NoSuchAlgorithmException, JsonParseException, JsonMappingException, IOException, ServletException
	{
		String JWT = Security.generate_JWT(user_id, user_role);
		Cookie jwt_cookie = new Cookie("user_token",JWT);
		jwt_cookie.setHttpOnly(true);
		jwt_cookie.setMaxAge(3600); 
		response.addCookie(jwt_cookie);
		String temp_cookie_value = Character.toUpperCase(user_auth_type.charAt(0))+"-"+Character.toUpperCase(user_role.charAt(0));
		Cookie temp_cookie = new Cookie("Z_AUTHUSER", temp_cookie_value);
		temp_cookie.setMaxAge(3600);
		response.addCookie(temp_cookie);
		//response.addHeader("Set-Cookie", "user_token="+JWT+"; Secure; SameSite=None; Path=/; HttpOnly; max-age=3600");
		//response.addHeader("Set-Cookie", "Z_AUTHUSER="+temp_cookie_value+";  Path=/; max-age=3600");
	}
}

