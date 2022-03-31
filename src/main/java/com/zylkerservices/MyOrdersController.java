package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MyOrdersController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		int user_id = (Integer) jwt.get("user_id");
		if(jwt.get("user_role").equals("customer"))
		{
			request.setAttribute("customer_orders", CustomerRepository.getAllCustomerOrders(user_id));
			RequestDispatcher rd = request.getRequestDispatcher("/customerOrders.jsp");
			rd.forward(request, response);
		}
		else if(jwt.get("user_role").equals("partner"))
		{
			int limit = Integer.parseInt(Security.sanitize(request.getParameter("limit")));
			request.setAttribute("partner_orders", PartnerRepository.getAllPartnerOrders(user_id, limit, request));
			RequestDispatcher rd = request.getRequestDispatcher("/partnerOrders.jsp");
			rd.forward(request, response);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	}

}
