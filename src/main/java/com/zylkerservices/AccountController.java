package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;

import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.map.ObjectMapper;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class AccountController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		String user_role = (String) jwt.get("user_role");
		int user_id = (Integer) jwt.get("user_id");
		RequestDispatcher rd;
		switch(user_role)
		{
		      case "customer":
		    	    request.setAttribute("customer_data", CustomerRepository.getCustomerProfileInfo(user_id));
			 	    rd = request.getRequestDispatcher("/customer-profile.jsp");
				    rd.forward(request, response);
		    	    break;
		      case "partner":
		    	    request.setAttribute("partner_data", PartnerRepository.getPartnerProfileInfo(user_id));
					rd = request.getRequestDispatcher("/partner-profile.jsp");
					rd.forward(request, response);
		    	    break;
		      case "admin":
		    	    String page = "/"+Security.sanitize(request.getParameter("page"));
		    	    rd = request.getRequestDispatcher(page);
		    	    rd.forward(request, response);
		    	    break;
		      default:
		    	  response.sendRedirect("index.jsp");
		    	  break;
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
   	    ObjectMapper mapper = new ObjectMapper();
   	    HashMap<String, Object> jwt = (HashMap) UserRepository.fetchJWT(request);
   	    int user_id = (Integer) jwt.get("user_id");
   	    String action = Security.sanitize(request.getParameter("update"));
		switch(action)
		{
		    case "customer_profile_info":
		    	Customer customer = mapper.readValue(request.getReader(), Customer.class);
		    	customer.setCustomer_id(user_id);   	
		    	AccountService.updateCustomerProfile(customer, request, response);
		    	break;
		    case "partner_profile_info":
		    	Partner partner = mapper.readValue(request.getReader(), Partner.class);
		    	partner.setPartner_id(user_id);
		    	AccountService.updatePartnerProfile(partner,request, response);
		    	break;
		    case "partner_add_new_service":
		    	HashMap<String, Object> partnerNewServiceMap = mapper.readValue(request.getReader(), HashMap.class);
		    	int partner_id = (int) jwt.get("user_id");
		    	String service_name = (String) partnerNewServiceMap.get("service_name");
		    	String service_location = (String) partnerNewServiceMap.get("service_location");
		    	int service_charge = Integer.parseInt((String)partnerNewServiceMap.get("service_charge"));
		    	String csrf = (String) partnerNewServiceMap.get("csrf");
		    	String service_image = (String) partnerNewServiceMap.get("service_image");
		    	AccountService.addNewPartnerService(request, response, partner_id, service_name, service_location, service_charge, csrf, service_image);
		    	break;
		    case "admin_add_new_service":
		    	String newService = request.getParameter("newServiceName");
		    	AccountService.addNewService(newService, request, response);
		    	break;
		    case "reset_user_password":
		    	HashMap<String, String> passwordResetData = mapper.readValue(request.getReader(), HashMap.class);
		    	AccountService.resetCustomerPassword(passwordResetData.get("current_password"), passwordResetData.get("new_password"), passwordResetData.get("csrf"), request, response);
		    	break;
		    case "add_to_favourites":
		    	HashMap<String, Object> addToFavourites = mapper.readValue(request.getReader(), HashMap.class);
		    	int partner_id_fav = (Integer)addToFavourites.get("partner_id");
		    	String csrf_fav = (String) addToFavourites.get("csrf");
		    	String serviceName = (String) addToFavourites.get("service_name");
		    	String serviceLocation = (String) addToFavourites.get("service_location");
		    	int customer_id = (Integer) jwt.get("user_id");
		    	AccountService.addPartnerToFavourites(customer_id, partner_id_fav , csrf_fav, serviceName, serviceLocation, request, response);
		    	break;
		    case "update_dp":
		    	HashMap<String, String> updateDpMap = mapper.readValue(request.getReader(), HashMap.class);
		    	String csrf_dp = (String) updateDpMap.get("csrf");
		    	String dp_url = (String) updateDpMap.get("url");
		    	AccountService.updateDpURL(user_id, dp_url, csrf_dp, request, response);
		    	break;
			default:
		    	response.sendRedirect("index.jsp");
				break;
		}
	}

}
