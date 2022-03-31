package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class FavouritesController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		int customer_id = (Integer) jwt.get("user_id");
	    List<HashMap<String, Object>> favouritePartners = CustomerRepository.fetchAllFavouritePartners(customer_id);
	    request.setAttribute("favouritePartners", favouritePartners);
		RequestDispatcher rd = request.getRequestDispatcher("/favourites.jsp");
		rd.forward(request, response);
		
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		
		
	}

}
