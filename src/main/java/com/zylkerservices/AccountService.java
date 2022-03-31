package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.json.JSONObject;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class AccountService {
	
	public static void updatePartnerProfile(Partner partner, HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		if(jwt.get("csrf").equals(partner.getCsrf()))
		{
		    String executionResult = PartnerRepository.updateProfile(partner, request, response);
		    if(!executionResult.equals("updated"))
		    {
			    response.sendError(400);
		    }
		}
		else
		{
			response.sendError(400);
		}
	}
	
	public static void updateCustomerProfile(Customer customer, HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		//if(jwt.get("csrf").equals(customer.getCsrf()))
		{
		    String executionResult = CustomerRepository.updateProfile(customer, request, response);
		    if(!executionResult.equals("updated"))
		    {
			    response.sendError(400);
		    }
		}
		//else
		{
			//response.sendError(400);
		}
	}
	
	public static void resetCustomerPassword(String currentPassword, String newPassword, String csrf, HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		if(jwt.get("csrf").equals(csrf))
		{
			int user_id = (Integer) jwt.get("user_id");
			String executionResult = UserRepository.resetPassword(user_id, currentPassword, newPassword);
			PrintWriter out = response.getWriter();
			JSONObject jsonResponse = new JSONObject();
			response.setContentType("application/json");
			jsonResponse.put("passwordChange", executionResult);
			out.print(jsonResponse);
			out.flush();
			if(!executionResult.equals("success"))
			{
				response.sendError(401); 
			}
		}
		else
		{
			response.sendError(401, "csrf-mis-match");
		}
	}
	
	public static void addNewPartnerService(HttpServletRequest request, HttpServletResponse response,int partner_id, String service_name, String service_location, int service_charge, String csrf, String service_image) throws IOException
	{
		int service_id = PartnerRepository.getServiceId(service_name);
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		if(jwt.get("csrf").equals(csrf))
		{
		    String executionResult = PartnerRepository.partnerServiceUpdate(partner_id, service_id, service_charge, service_location, service_image);
		    if(!executionResult.equals("success"))
		    {
			    response.sendError(500);
		    }
		}
		else
		{
			response.sendError(400);
		}
	}
	
	public static void addPartnerToFavourites(int customer_id, int partner_id,String csrf, String serviceName, String serviceLocation, HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		HashMap<String, Object> jwt = (HashMap) request.getAttribute("jwt_verification");
		
		if(jwt.get("csrf").equals(csrf) && jwt.get("user_role").equals("customer"))
		{
			String executionResult = PartnerRepository.addPartnerToFavourites(customer_id, partner_id, serviceName, serviceLocation); 
			if(!executionResult.equals("success"))
			{
				response.sendError(500);
			}
		}
		else
		{
			response.sendError(400);
		}
	}
	
	public static void updateDpURL(int userId, String dpURL, String csrf, HttpServletRequest request, HttpServletResponse response) throws JsonParseException, JsonMappingException, IOException
	{
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		try
		{
			if(jwt.get("csrf").equals(csrf))
			{
				String userRole = (String) jwt.get("user_role");
				String profile = userRole+"_profile";
				String column = userRole+"_dp_url";
				String id = userRole+"_id";
				String updateDpSql = "UPDATE "+profile+" SET "+column+" = ? WHERE "+id+" = ?"; 
				PreparedStatement stmt = Database.getConnection().prepareStatement(updateDpSql);
				stmt.setString(1, dpURL);
				stmt.setInt(2, userId);
				stmt.executeUpdate();
				response.setStatus(202);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService.java", "updateDpURL", e.toString());
		}
	}
	
	public static void addNewService(String newServiceName, HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		String executionResult = AdminRepository.createNewService(newServiceName);
		if(!executionResult.equals("created"))
		{
			response.sendError(400);
		}
	}
	
	public static int getTotalCustomersCount()
	{
		try
		{
		    String sql = "SELECT count(*) FROM user_credentials WHERE user_role LIKE \"%customer%\"";
		    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
		    ResultSet rs = stmt.executeQuery();
		    while(rs.next())
		    {
		        return rs.getInt(1);
		    }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService.java", "getTotalCustomersCount", e.toString());
		}
		return -1;
	}
	
	public static int getTotalPartnersCount()
	{
		try
		{
		    String sql = "SELECT count(*) FROM user_credentials WHERE user_role LIKE \"%partner%\"";
		    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
		    ResultSet rs = stmt.executeQuery();
		    while(rs.next())
		    {
		        return rs.getInt(1);
		    }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService.java", "getTotalPartnersCount", e.toString());
		}
		return -1;
	}
	
}
