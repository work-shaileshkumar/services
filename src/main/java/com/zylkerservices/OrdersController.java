package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;

import org.codehaus.jackson.map.ObjectMapper;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class OrdersController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		ObjectMapper mapper = new ObjectMapper(); 
	    String action = Security.sanitize(request.getParameter("action"));
	    switch(action)
	    {
	        case  "confirmBooking":
	    	    String partnerName = request.getParameter("partnerName");
	    	    String serviceName = request.getParameter("serviceName");
	    	    String serviceLocation = request.getParameter("serviceLocation");
	    	    int serviceId = PartnerRepository.getServiceId(serviceName);
	    	    int partnerId = Integer.parseInt(request.getParameter("partnerId"));
	        	int orderValue = PartnerRepository.getServiceCharge(partnerId, serviceId, serviceLocation);
	        	HashMap<String, Object> orderConfirmationDetails = OrderService.calculateOrderCharges(partnerName, serviceName, serviceLocation, serviceId, orderValue);
	        	request.setAttribute("orderCharges", orderConfirmationDetails);
	        	RequestDispatcher rd = request.getRequestDispatcher("/confirmBooking.jsp");
	        	rd.forward(request, response);
	        	break;
	        default:
	        	response.sendRedirect("index.jsp");
	        	break;
	    }
		RequestDispatcher rd = request.getRequestDispatcher("confirmBooking.jsp");
		rd.forward(request,  response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		ObjectMapper mapper = new ObjectMapper(); 
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		int customerId = (Integer) jwt.get("user_id");
		if(jwt.get("user_role").equals("customer"))
		{
		    String action = request.getParameter("action");
		    switch(action)
		    {
		        case "create_new_order":
		        	HashMap<String, Object> orderMap = mapper.readValue(request.getReader(), HashMap.class);
		        	String csrf = (String) orderMap.get("csrf");
		        	int partnerId = (Integer) orderMap.get("partner_id");
		        	int serviceId = PartnerRepository.getServiceId((String) orderMap.get("service_name"));
		        	String serviceLocation = (String) orderMap.get("service_location");
		        	int orderValue = PartnerRepository.getServiceCharge(partnerId, serviceId, serviceLocation);
		        	if(jwt.get("csrf").equals(orderMap.get("csrf")))
		    	        OrderService.createNewOrder(customerId, partnerId, serviceId, serviceLocation, orderValue, csrf, request, response);
		    	    break;
		        case "submit_rating":
		        	HashMap<String, Object> orderRating = mapper.readValue(request.getReader(), HashMap.class);
		        	String csrf_rating = (String) orderRating.get("csrf");
		        	int orderId = (Integer) orderRating.get("order_id");
		        	int rating = (Integer) orderRating.get("rating");
		        	String review  = (String) orderRating.get("review");
		        	int customerId_submit = (Integer) orderRating.get("customer_id");
		        	int partnerId_submit = (Integer) orderRating.get("partner_id");
		        	OrderService.submitRating(orderId, rating, customerId_submit, partnerId_submit, review, csrf_rating, request, response);
		        	break;
		        default:
		    	    response.sendRedirect("index.jsp");
		    	    break;
		    }
		}
		else if(jwt.get("user_role").equals("partner"))
		{
			String action = request.getParameter("action");
			switch(action)
			{
	            case "cancel_order":
	        	    HashMap<String, Object> cancelOrderMap = mapper.readValue(request.getReader(), HashMap.class);
	        	    String csrf_cancel_order = (String) cancelOrderMap.get("csrf");
	        	    int orderId = (Integer) cancelOrderMap.get("order_id");
	        	    double amountValue = Double.parseDouble((String)cancelOrderMap.get("order_value"));
	        	    int customer_id = (Integer) cancelOrderMap.get("customer_id");
	        	    int partnerId = (Integer) cancelOrderMap.get("partner_id");
	        	    if(jwt.get("csrf").equals(cancelOrderMap.get("csrf")))
	        	       OrderService.updateOrderStatus(orderId, "cancelled by partner", customer_id, -1.0*amountValue, partnerId, response);
	        	    break;
	            case "accept_order":
	        	    HashMap<String, Object> acceptOrderMap = mapper.readValue(request.getReader(), HashMap.class);
	        	    String csrf_accept_order = (String) acceptOrderMap.get("csrf");
	        	    orderId = (Integer) acceptOrderMap.get("order_id");
	        	    double amountValue_accept = Double.parseDouble((String)acceptOrderMap.get("order_value"));
	        	    int customer_id_accept = (Integer) acceptOrderMap.get("customer_id");
	        	    int partner_id_accept = (Integer) acceptOrderMap.get("partner_id");
	        	    System.out.println(partner_id_accept+" "+jwt.get("csrf"));
	        	    if(jwt.get("csrf").equals(acceptOrderMap.get("csrf")))
	        	        OrderService.updateOrderStatus(orderId, "accepted by partner", customer_id_accept, -1.0*amountValue_accept,partner_id_accept, response);
	        	    break;
			    default:
			    	response.sendRedirect("index.jsp");
			    	break;
			}
		}
		else
		{
			response.sendError(400);
		}
	}

}
