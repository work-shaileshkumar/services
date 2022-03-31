package com.zylkerservices;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class CustomerRepository {

	public static String updateProfile(Customer customer, HttpServletRequest request, HttpServletResponse response) throws IOException 
	{
		try
		{
		    String updateCustomerProfileSql = "INSERT INTO customer_profile(customer_id, customer_name, customer_phno) VALUES (?,?,?) ON DUPLICATE KEY UPDATE customer_name=?, customer_phno=?";
		    PreparedStatement updateCustomerProfileStmt = Database.getConnection().prepareStatement(updateCustomerProfileSql);
		    updateCustomerProfileStmt.setInt(1, customer.getCustomer_id());
		    updateCustomerProfileStmt.setString(2, customer.getCustomer_name());
		    updateCustomerProfileStmt.setLong(3, customer.getCustomer_phno());
		    updateCustomerProfileStmt.setString(4, customer.getCustomer_name());
		    updateCustomerProfileStmt.setLong(5, customer.getCustomer_phno());
		    int rowsAffected = updateCustomerProfileStmt.executeUpdate();
		    if(rowsAffected > 0)
		    {
		    	Logs.addUserLog(customer.getCustomer_id(), "Customer Profile Updated");
			    HttpSession session = request.getSession();
			    session.setAttribute("name", customer.getCustomer_name()==null ? null : customer.getCustomer_name().split(" ")[0]);
			    session.setAttribute("dp_url", customer.getCustomer_dp_url()==null ? null : customer.getCustomer_dp_url());
                return "updated";
		    }
			else
			{
				return "serverError";
			}
		}
		catch(Exception e)
		{
			return "serverError";
		}
	}
	
	public static Customer getCustomerProfileInfo(int user_id)
	{
		Customer customer = new Customer();
		try
		{
			String fetchCustomerProfileInfoSql = "SELECT customer_profile.customer_name, customer_profile.customer_phno, user_credentials.email, customer_dp_url FROM customer_profile INNER JOIN user_credentials ON customer_profile.customer_id = user_credentials.user_id AND customer_id = ?";
			PreparedStatement fetchCustomerProfileInfoStmt = Database.getConnection().prepareStatement(fetchCustomerProfileInfoSql);
			fetchCustomerProfileInfoStmt.setInt(1, user_id);
			ResultSet rs = fetchCustomerProfileInfoStmt.executeQuery();
			while(rs.next())
			{
				customer.setCustomer_name(rs.getString(1));
				customer.setCustomer_phno(rs.getLong(2));
				customer.setCustomer_email(rs.getString(3));
				customer.setCustomer_dp_url(rs.getString(4));
			}
			return customer;
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService", "getCustomerProfileInfo", e.toString());
		}
		return customer;
	}
		
	public static List<HashMap<String, Object>> fetchAllFavouritePartners(int customer_id)
	{
		List<HashMap<String, Object>> favouritePartners = new ArrayList<HashMap<String, Object>>();
		try
		{
		    String fetchPartnerIdsSql = "SELECT partner_id, service_name, service_location FROM favourites WHERE customer_id = ? order by row_id desc"; 
		    PreparedStatement fetchPartnerIdsStmt = Database.getConnection().prepareStatement(fetchPartnerIdsSql);
		    fetchPartnerIdsStmt.setInt(1, customer_id);
		    ResultSet rs = fetchPartnerIdsStmt.executeQuery();
		    while(rs.next())
		    {
		    	int partner_id = rs.getInt(1);
		    	String serviceName = rs.getString(2);
		    	String serviceLocation = rs.getString(3);
		    	String fetchFavouritePartnersSql = "SELECT partner_profile.partner_name, favourites.service_name, favourites.service_location, partner_services.service_charge, partner_profile.partner_id, partner_profile.partner_dp_url FROM favourites INNER JOIN partner_profile ON favourites.partner_id = partner_profile.partner_id AND favourites.partner_id = ? INNER JOIN partner_services ON partner_services.partner_id = favourites.partner_id AND partner_services.service_id = ? AND partner_services.service_location = ?;"; 
		        PreparedStatement fetchPartnerDataStmt = Database.getConnection().prepareStatement(fetchFavouritePartnersSql);
		        fetchPartnerDataStmt.setInt(1,partner_id);
		        fetchPartnerDataStmt.setInt(2, PartnerRepository.getServiceId(serviceName));
		        fetchPartnerDataStmt.setString(3, serviceLocation);
		        ResultSet rs1 = fetchPartnerDataStmt.executeQuery();
		        HashMap<String, Object> partnerData = new HashMap<String, Object>();
		        while(rs1.next())
		        {
		        	partnerData.put("partner_name", rs1.getString(1));
		        	partnerData.put("service_name", rs1.getString(2));
		        	partnerData.put("service_location", rs1.getString(3));
		        	partnerData.put("service_charge", rs1.getInt(4));
		        	partnerData.put("partner_id", rs1.getInt(5));
		        	partnerData.put("partner_dp_url", rs1.getString(6));
		        }
		        favouritePartners.add(partnerData);
		    }     
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "fetchAllFavouritePartners", e.toString());
		}
		return favouritePartners;
	}
	
	public static List<HashMap<String, Object>> getAllCustomerOrders(int customer_id)
	{
		List<HashMap<String, Object>> customerOrders = new ArrayList<HashMap<String, Object>>();
        try
        {
        	String getAllCustomerOrdersSql = "SELECT partner_profile.partner_name, orders.service_id, orders.service_location, orders.order_value, orders.order_created_date, orders.order_id, order_tracking_status.order_status, order_tracking_status.timestamp, partner_profile.partner_id, partner_services.service_image, ratings_and_reviews.rating FROM orders INNER JOIN partner_profile ON partner_profile.partner_id = orders.partner_id AND orders.customer_id = ? INNER JOIN order_tracking_status ON order_tracking_status.order_id = orders.order_id INNER JOIN partner_services ON partner_services.service_id = orders.service_id AND partner_services.partner_id = orders.partner_id AND orders.service_location = partner_services.service_location LEFT JOIN ratings_and_reviews ON ratings_and_reviews.order_id = orders.order_id ORDER BY orders.order_id DESC;";
        	PreparedStatement getAllCustomerOrdersStmt = Database.getConnection().prepareStatement(getAllCustomerOrdersSql);
        	getAllCustomerOrdersStmt.setInt(1, customer_id);
        	ResultSet rs = getAllCustomerOrdersStmt.executeQuery();
        	while(rs.next())
        	{
        		HashMap<String, Object> customerOrder = new HashMap<String, Object>();
        		customerOrder.put("partner_name", rs.getString(1));
        		customerOrder.put("service_name", PartnerRepository.getServiceName(rs.getInt(2)));
        		customerOrder.put("service_location", rs.getString(3));
        		customerOrder.put("order_value", rs.getInt(4));
        		Timestamp t = (Timestamp) rs.getObject(5);
        		String bestTime = PartnerRepository.findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000);
        		customerOrder.put("order_created_date", bestTime);
        		customerOrder.put("order_id", rs.getInt(6));
        		customerOrder.put("order_status", rs.getString(7));
        		t = (Timestamp) rs.getObject(8);
        		bestTime = PartnerRepository.findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000);
        		customerOrder.put("order_last_updated", bestTime);
        		customerOrder.put("partner_id", rs.getInt(9));
        		customerOrder.put("service_image", rs.getString(10));
        		customerOrder.put("order_rating", rs.getInt(11));
        		customerOrders.add(customerOrder);
        	}
        }
        catch(Exception e)
        {
        	Logs.addDeveloperLog("CustomerRepository.java", "getAllCustomerOrders", e.toString());
        }
		return customerOrders;
	}
	
	public static double getWalletBalance(int customer_id)
	{
		double walletBalance = 0.0;
		try
		{
			String fetchWalletBalanceSql = "SELECT wallet_balance FROM customer_profile WHERE customer_id = ?";
			PreparedStatement fetchWalletBalanceStmt = Database.getConnection().prepareStatement(fetchWalletBalanceSql);
			fetchWalletBalanceStmt.setInt(1, customer_id);
			ResultSet rs = fetchWalletBalanceStmt.executeQuery();
			while(rs.next())
			{
				walletBalance = rs.getDouble(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "getWalletBalance", e.toString());
		}
		return walletBalance;
	}
	
	public static double getLockedWalletBalance(int customer_id)
	{
		double lockedWalletBalance = 0.0;
		try
		{
			String fetchLockedWalletBalanceSql = "SELECT locked_wallet_balance FROM customer_profile WHERE customer_id = ?";
			PreparedStatement fetchLockedWalletBalanceStmt = Database.getConnection().prepareStatement(fetchLockedWalletBalanceSql);
			fetchLockedWalletBalanceStmt.setInt(1, customer_id);
			ResultSet rs = fetchLockedWalletBalanceStmt.executeQuery();
			while(rs.next())
			{
				lockedWalletBalance = rs.getDouble(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "getLockedWalletBalance", e.toString());
		}
		return lockedWalletBalance;
	}
	
	public static int updateLockedWalletBalance(int customerId, double amount)
	{
		int numOfRowsAffected = -1;
		try
		{
			String updateLockedWalletSql = "UPDATE customer_profile SET locked_wallet_balance = locked_wallet_balance + ? WHERE customer_id = ?";
			PreparedStatement updateLockedWalletStmt = Database.getConnection().prepareStatement(updateLockedWalletSql);
			updateLockedWalletStmt.setDouble(1, amount);
			updateLockedWalletStmt.setInt(2, customerId);
			numOfRowsAffected = updateLockedWalletStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "updateLockedWalletBalance", e.toString());
		}
		return numOfRowsAffected;
	}
	
	public static int updateWalletBalance(int customerId, double amount)
	{
		int numOfRowsAffected = -1;
		try
		{
			String updateLockedWalletSql = "UPDATE customer_profile SET wallet_balance = wallet_balance - ? WHERE customer_id = ?";
			PreparedStatement updateLockedWalletStmt = Database.getConnection().prepareStatement(updateLockedWalletSql);
			updateLockedWalletStmt.setDouble(1, amount);
			updateLockedWalletStmt.setInt(2, customerId);
			numOfRowsAffected = updateLockedWalletStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "updateWalletBalance", e.toString());
		}
		return numOfRowsAffected;
	}
	
	public static List<HashMap<String, Object>> getAllCustomerTransactions(int customer_id)
	{
		List<HashMap<String, Object>> customerTransactions = new ArrayList<HashMap<String, Object>>();
		try
		{
		    String getCustomerTransactionSql = "SELECT transactions.transaction_value, transactions.transaction_message, transactions.transaction_time, partner_profile.partner_name FROM transactions LEFT JOIN partner_profile ON transactions.receiver_id = partner_profile.partner_id WHERE transactions.sender_id = ? ORDER BY transactions.row_id DESC;";
	        PreparedStatement customerTransactionStmt = Database.getConnection().prepareStatement(getCustomerTransactionSql);
	        customerTransactionStmt.setInt(1, customer_id);
	        ResultSet rs = customerTransactionStmt.executeQuery();
		    while(rs.next())
		    {
		    	HashMap<String, Object> customerTransaction = new HashMap<String, Object>();
		    	customerTransaction.put("transaction_value", rs.getDouble(1));
		    	customerTransaction.put("transaction_message", rs.getString(2));
		    	Timestamp t = (Timestamp) rs.getObject(3);
		    	String bestTime = PartnerRepository.findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000);
		    	customerTransaction.put("transaction_time", bestTime);
		    	customerTransaction.put("partner_name", rs.getString(4));
		    	customerTransactions.add(customerTransaction);
		    }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "getAllCustomerTransactions", e.toString());
		}
		return customerTransactions;
	}
}
