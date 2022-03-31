package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class PartnerProfileViewController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String action = Security.sanitize(request.getParameter("action"));
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		if(jwt!=null)
		{
		    int partner_id = Integer.parseInt(Security.sanitize(request.getParameter("partnerId")));
		    int customer_id = (Integer) jwt.get("user_id");
    	    String serviceName = request.getParameter("serviceName");
    	    String serviceLocation = request.getParameter("serviceLocation");
		    switch(action) 
		    {
		        case "viewPartnerProfile":
		    	    if(jwt.get("user_role").equals("customer"))
		    	    {
		    	        SearchService.addViewCount(customer_id, partner_id, serviceName, serviceLocation);
		    	    }
		    	    HashMap<String, Object> partner = PartnerRepository.getCompletePartnerInfo(partner_id, serviceName, serviceLocation, customer_id);
		    	    request.setAttribute("jwt", jwt);
		    	    request.setAttribute("partner_data", partner);
		    	    RequestDispatcher rd = request.getRequestDispatcher("/partner-info.jsp");
		    	    rd.forward(request, response);
		    	    break;
		        default:
		    	    response.sendRedirect("index.jsp");
		    	    break;
		    }
		}
		else
		{
			System.out.println("JWT is null");
			response.sendRedirect("index.jsp");
		}
	}

}
