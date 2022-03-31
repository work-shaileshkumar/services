package com.zylkerservices;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;

import org.codehaus.jackson.map.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UserController extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		ObjectMapper mapper = new ObjectMapper();
		//System.out.println(request.getRemoteAddr());
		User obj = null;
		String service = request.getParameter("service");
		switch(service)
		{
			case "signin":
				obj = mapper.readValue(request.getReader(), User.class); // JSON to POJO
				UserService.signin(request, response, obj);
				break;
			case "signup":
				obj = mapper.readValue(request.getReader(), User.class); // JSON to POJO
				UserService.signup(request, response, obj);
				break;
			case "signout":
				String csrf = request.getParameter("csrf");
				UserService.signout(request, response, csrf);
				break;
			case "checkIfIsRegisteredEmail":
				HashMap<String, Object> checkIsRegisteredUserMap = mapper.readValue(request.getReader(), HashMap.class);
				String email = (String) checkIsRegisteredUserMap.get("email");
				UserRepository.checkIsRegisteredUser(email, response);
				System.out.println(checkIsRegisteredUserMap);
				break; 
			default:
				response.sendError(400);
				break;
		}
	}

}