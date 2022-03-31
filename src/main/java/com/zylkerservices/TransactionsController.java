package com.zylkerservices;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.util.HashMap;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class TransactionsController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { 
		
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		int partner_id = (Integer) jwt.get("user_id");
		if(jwt.get("user_role").equals("partner"))
		{
			request.setAttribute("partnerTransactions", TransactionService.getAllPartnerTransactions(partner_id, response)); 
			RequestDispatcher rd = request.getRequestDispatcher("/partnerTransactions.jsp");
			rd.forward(request, response);
		}
		
	}

}
