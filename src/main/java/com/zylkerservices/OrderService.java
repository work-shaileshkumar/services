package com.zylkerservices;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.HashMap;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class OrderService {
	
	public static void createNewOrder(int customerId, int partnerId, int serviceId, String serviceLocation, int orderValue, String csrf,HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		if(orderValue != -1 && jwt.get("csrf").equals(csrf))
		{ 
			try 
			{
				String createNewOrderSql = "INSERT INTO orders(customer_id, partner_id, service_id, service_location, order_value) VALUES (?, ?, ?, ?, ?);";
				PreparedStatement createNewOrderStmt = Database.getConnection().prepareStatement(createNewOrderSql,PreparedStatement.RETURN_GENERATED_KEYS);
				createNewOrderStmt.setInt(1, customerId);
				createNewOrderStmt.setInt(2, partnerId);
				createNewOrderStmt.setInt(3, serviceId);
				createNewOrderStmt.setString(4, serviceLocation);
				createNewOrderStmt.setInt(5, orderValue);
				int numOfRowsAffected = createNewOrderStmt.executeUpdate();
				ResultSet rs = createNewOrderStmt.getGeneratedKeys();
				int order_id = -1;
				if(rs.next()) order_id = rs.getInt(1);
				if (numOfRowsAffected > 0 && order_id >= 10000) 
				{
					String orderStatusSql = "INSERT INTO order_tracking_status(order_id, order_status) VALUES (?, ?)";
					PreparedStatement orderStatusStmt = Database.getConnection().prepareStatement(orderStatusSql);
					orderStatusStmt.setInt(1, order_id);
					orderStatusStmt.setString(2, "created");
					numOfRowsAffected = orderStatusStmt.executeUpdate();
					double totalCharges = orderValue + calculateExtraCharges(orderValue);
					if(numOfRowsAffected > 0)
					{
						String lockedWalletBalanceSql = "UPDATE customer_profile SET locked_wallet_balance = locked_wallet_balance + ? WHERE customer_id = ?";
						PreparedStatement lockedWalletBalanceStmt = Database.getConnection().prepareStatement(lockedWalletBalanceSql);
						lockedWalletBalanceStmt.setDouble(1, totalCharges);
						lockedWalletBalanceStmt.setInt(2, customerId);
						numOfRowsAffected = lockedWalletBalanceStmt.executeUpdate();
						if(numOfRowsAffected > 0)
						{
							 PartnerRepository.updteOrdersCount(partnerId);
							 response.setStatus(202);
						}
					}
				}
			} 
			catch (Exception e) 
			{
				Logs.addDeveloperLog("OrderService.java", "createNewOrder", e.toString());
				response.sendError(400);
			}
		}
		else if(orderValue == -1)
		{
			response.sendError(400);
		}
	}
	
	public static HashMap<String, Object> calculateOrderCharges(String partnerName, String serviceName, String serviceLocation, int serviceId, int orderValue)
	{
		HashMap<String, Object> orderCharges = new HashMap<String, Object>();
		orderCharges.put("partner_name", partnerName);
		orderCharges.put("service_name", serviceName);
		orderCharges.put("service_location", serviceLocation);
		orderCharges.put("service_id", serviceId);
		orderCharges.put("order_value",orderValue);
		double tax = calculateTax(orderValue);
		double bookingCharges = calculateBookingCharge(orderValue);
		double totalCharges = bookingCharges+tax+(orderValue*1.0);
		orderCharges.put("tax", tax);
		orderCharges.put("booking_charges", bookingCharges);
		orderCharges.put("total_charges", totalCharges);
		return orderCharges;
	}
	
	public static void updateOrderStatus(int orderId, String orderStatus, int customerId, double amountValue,int partnerId, HttpServletResponse response) 
	{
		try
		{
			Timestamp timestamp = Timestamp.from(Instant.now()); 
		    String updateOrderSql = "UPDATE order_tracking_status SET order_status = ?, timestamp = ? WHERE order_id = ? AND order_status like \"created\"";
		    PreparedStatement updateOrderStmt = Database.getConnection().prepareStatement(updateOrderSql);
		    updateOrderStmt.setString(1, orderStatus);
		    updateOrderStmt.setTimestamp(2, timestamp);
		    updateOrderStmt.setInt(3, orderId);
		    int numOfRowsAffected = updateOrderStmt.executeUpdate();
		    if(orderStatus.equals("accepted by partner") && numOfRowsAffected>0)
		    {
		    	numOfRowsAffected = CustomerRepository.updateLockedWalletBalance(customerId, amountValue);
		    	numOfRowsAffected = CustomerRepository.updateWalletBalance(customerId, -1.0*amountValue);
		    	WalletService.addTransaction(orderId, customerId, partnerId, amountValue, "paid");
		    	PartnerRepository.updteOrdersAcceptedCount(partnerId);
		    }
		    else if(orderStatus.equals("cancelled by partner") && numOfRowsAffected>0)
		    {
		    	numOfRowsAffected = CustomerRepository.updateLockedWalletBalance(customerId, amountValue);
		    }
		    if(numOfRowsAffected > 0)
			    response.setStatus(202);
		    else
			    response.sendError(400);
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("OrderService.java", "updateOrderStatus", e.toString());
		}
	}
	
	public static void submitRating(int orderId, int rating, int customerId, int partnerId, String review, String csrf, HttpServletRequest request, HttpServletResponse response)
	{
		try
		{
			HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
			if(jwt.get("csrf").equals(csrf))
			{
				boolean alreadyRated = false;
				String checkRatingSql = "SELECT row_id FROM ratings_and_reviews WHERE order_id = ?";
				PreparedStatement checkRatingStmt = Database.getConnection().prepareStatement(checkRatingSql);
				checkRatingStmt.setInt(1, orderId);
				ResultSet rs = checkRatingStmt.executeQuery();
				while(rs.next())
				{
					alreadyRated = true;
				}
				if(!alreadyRated)
				{
				    String submitRatingSql = "INSERT INTO ratings_and_reviews(order_id, customer_id, partner_id, rating, review) VALUES (?, ?, ?, ?, ?);";
				    PreparedStatement submitRatingStmt = Database.getConnection().prepareStatement(submitRatingSql);
				    submitRatingStmt.setInt(1, orderId);
				    submitRatingStmt.setInt(2, customerId);
				    submitRatingStmt.setInt(3, partnerId);
				    submitRatingStmt.setInt(4, rating);
				    submitRatingStmt.setString(5, review);
				    submitRatingStmt.executeUpdate();
				    
				    String avgRatingSql = "SELECT AVG(rating) FROM ratings_and_reviews WHERE partner_id = ?";
				    PreparedStatement avgRatingStmt = Database.getConnection().prepareStatement(avgRatingSql);
				    avgRatingStmt.setInt(1, partnerId);
				    rs = avgRatingStmt.executeQuery();
				    double avg = 0.0;
				    while(rs.next())
				    {
				    	 avg = rs.getDouble(1);
				    }
				    String updateAvgRatingSql = "UPDATE partner_profile SET average_rating = ? WHERE partner_id = ?";
				    PreparedStatement updateAvgRatingStmt = Database.getConnection().prepareStatement(updateAvgRatingSql);
				    updateAvgRatingStmt.setDouble(1, avg);
				    updateAvgRatingStmt.setInt(2, partnerId);
				    updateAvgRatingStmt.executeUpdate();
				    response.setStatus(200); 
				}
				else
				{
					response.setStatus(401);
				}
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("OrderService.java", "submitRating", e.toString());
		}
	}
	
	public static double calculateExtraCharges(int order_value)
	{
		double extraCharges = 0.0;
		extraCharges = calculateTax(order_value) + calculateBookingCharge(order_value);
		return extraCharges;
	}
	
	public static double calculateTax(int serviceCharge)
	{
		return (18*serviceCharge*1.0)/100;
	}
	
	public static double calculateBookingCharge(int serviceCharge)
	{
		double bookingCharge = (2*serviceCharge*1.0)/100;
		if(bookingCharge >= 20.0) bookingCharge = 20.0;
		return bookingCharge;
	}
	
}
