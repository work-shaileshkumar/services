package com.zylkerservices;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class searchController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{	
		String selectedService = Security.sanitize(request.getParameter("serviceName"));
		String serviceLocation = Security.sanitize(request.getParameter("serviceLocation"));
		String searchText = Security.sanitize(request.getParameter("searchTxt")==null ? "" : request.getParameter("searchTxt"));
		String sortType = Security.sanitize(request.getParameter("sortType")==null ? "Relevance" : request.getParameter("sortType"));
		if(request.getParameter("serviceLocation").equals(serviceLocation) && request.getParameter("serviceName").equals(selectedService))
		{
		    if(!selectedService.equals("") && !selectedService.equals("Select a service from dropdown") && !serviceLocation.equals("City"))
		    {
			    int serviceId = PartnerRepository.getServiceId(selectedService);
			    List<Partner> relevantPartners = SearchService.findRelevantPartners(serviceId, serviceLocation, searchText, sortType);
			    request.setAttribute("search_results", relevantPartners);
			    RequestDispatcher rd = request.getRequestDispatcher("/search.jsp");
			    rd.forward(request, response);
		    }
	 	    else
		    {
			    response.sendRedirect("index.jsp");
		    }
		}
		else
		{
			// sanitization of input failed
			response.sendRedirect("index.jsp");
			System.out.println("Unexpected values found in URL");
		}
	}
}
