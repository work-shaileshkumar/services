package com.zylkerservices;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class AnalyticsController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		if(jwt.get("user_role").equals("partner"))
		{
			int partner_id = (Integer) jwt.get("user_id");
			int numOfRecords = 25; 
			try{numOfRecords = Integer.parseInt(Security.sanitize((String) request.getAttribute("limit")));}catch(Exception e) {/*Not a number in url*/ }
			List<HashMap<String, Object>> customersData = PartnerRepository.getAllCustomerViews(partner_id, numOfRecords);
			request.setAttribute("viewed_customers_data", customersData);
			RequestDispatcher rd = request.getRequestDispatcher("/analytics.jsp");
			rd.forward(request, response);
		}
		else
		{
			response.getWriter().println("You don't have access to this page");
		}
	}
}
