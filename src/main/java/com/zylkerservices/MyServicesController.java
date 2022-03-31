package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class MyServicesController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		HashMap<String, Object> user_token = (HashMap) request.getAttribute("jwt_verification");
		String user_role = (String) user_token.get("user_role");
		if(user_role.equals("partner"))
		{
			
			RequestDispatcher rd = request.getRequestDispatcher("/my-services.jsp");
			rd.forward(request, response);
		}
		else
		{
			PrintWriter out = response.getWriter();
			out.println("You don't have access to this page");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		doGet(request, response);
	}

}
