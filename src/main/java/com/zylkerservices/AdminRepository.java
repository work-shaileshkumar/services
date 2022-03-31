package com.zylkerservices;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class AdminRepository {
	
	public static String createNewService(String serviceName)
	{
		try
		{
		    String createServiceSql = "INSERT INTO services(service_name) VALUES(\""+serviceName+"\");";
		    PreparedStatement createServiceStmt = Database.getConnection().prepareStatement(createServiceSql);
		    createServiceStmt.executeUpdate();
		    return "created";
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "createNewService", e.toString());
		}
		return "serverError";
	}
	
	public static double getTodaysCustomerSatisfactionRating()
	{
		double rating = 0.0;
		try
		{
			LocalDate myObj = LocalDate.now();
			String date = myObj.toString();
			String sql = "SELECT AVG(rating) FROM ratings_and_reviews WHERE timestamp like \"%"+date+"%\"; " ;
			PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			ResultSet rs = stmt.executeQuery();
			while(rs.next())
			{
				rating = rs.getDouble(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getTodaysCustomerSatisfaction", e.toString());
		}
		return rating;
	}
	
	public static List<String> getCustomerSatisfactionRating(int days)
	{
		double rating = 0.0;
		List<String> ratings = new ArrayList<String>();
		LocalDate date = LocalDate.now();
		try
		{
			for(int i=7;i>=0;i--)
			{
				LocalDate pastDate = date.minusDays(i);
				String dateString = pastDate.toString();
				String sql = "SELECT AVG(rating) FROM ratings_and_reviews WHERE timestamp like \"%"+dateString+"%\"; " ;
				PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
				ResultSet rs = stmt.executeQuery();
				while(rs.next())
				{
					ratings.add(dateString+"-"+rs.getDouble(1));
				}
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getTodaysCustomerSatisfaction", e.toString());
		}
		return ratings;
	}
	
	
	public static double getCustomerSatisfactionRatingInLastWeek()
	{
		double rating = 0.0;
		try
		{
			LocalDate date = LocalDate.now();
			LocalDate lastWeek = date.minusDays(7);
			String lastWeekDateString = lastWeek.toString();
			String sql = "SELECT AVG(rating) FROM ratings_and_reviews WHERE timestamp >= "+lastWeekDateString+";" ;
			PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			ResultSet rs = stmt.executeQuery();
			while(rs.next())
			{
				rating = rs.getDouble(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getTodaysCustomerSatisfaction", e.toString());
		}
		return rating;
	}
	
	public static List<String> getOrdersCount(int days)
	{
		List<String> orders = new ArrayList<String>();
		try
		{
			LocalDate date =  LocalDate.now();
			for(int i=7;i>=0;i--)
			{
				LocalDate pastDate = date.minusDays(i);
				String pastDateString = pastDate.toString();
				String sql = "SELECT count(order_id) from orders WHERE order_created_date LIKE \"%"+pastDateString+"%\";";
			    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			    ResultSet rs = stmt.executeQuery();
			    while(rs.next())
			    {
			    	orders.add(pastDateString+"-"+rs.getInt(1));
			    }
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getCustomerOrders", e.toString());
		}
		return orders;
	}
	
	public static List<String> getLastWeekRevenue(int days)
	{
		List<String> revenues = new ArrayList<String>();
		try
		{
			LocalDate date =  LocalDate.now();
			for(int i=7;i>=0;i--)
			{
				LocalDate pastDate = date.minusDays(i);
				String pastDateString = pastDate.toString();
				String sql = "SELECT orders.order_value FROM orders INNER JOIN order_tracking_status ON orders.order_id = order_tracking_status.order_id AND order_tracking_status.order_status like \"%accepted%\" AND orders.order_created_date like \"%"+pastDateString+"%\";";  
			    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			    ResultSet rs = stmt.executeQuery();
			    double totalRevenue=0.0, totalTax = 0.0, totalProfit = 0.0;
			    while(rs.next())
			    {
			    	int amount = rs.getInt(1);
			    	double tax = OrderService.calculateTax(amount);
			    	double profit = OrderService.calculateBookingCharge(amount);
			    	totalRevenue += (amount*1.0);
			    	totalTax += tax;
			    	totalProfit += profit;
			    }
			    revenues.add(pastDateString+"#"+totalRevenue+"#"+totalProfit+"#"+totalTax);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getLastWeekRevenue", e.toString());
		}
		return revenues;
	}
	
	public static HashMap<String, Integer> getTopServicesByNumOfOrders(int days)
	{
		HashMap<String, Integer> topServicesByNumOfOrders = new HashMap<String, Integer>();
		try
		{
			LocalDate date = LocalDate.now();
			for(int i=30; i>=0; i--)
			{
				LocalDate pastDate = date.minusDays(i);
				String pastDateString = pastDate.toString();
			    String sql = "SELECT DISTINCT(services.service_name), COUNT(1) FROM orders INNER JOIN services ON services.service_id = orders.service_id WHERE orders.order_created_date like \"%"+pastDateString+"%\" GROUP BY services.service_name;";
			    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			    ResultSet rs = stmt.executeQuery();
			    
			    while(rs.next())
			    {
				    String serviceName = rs.getString(1);
				    int numOfOrders = rs.getInt(2);
				    String serviceOrder = serviceName+"#"+numOfOrders;
				    if(topServicesByNumOfOrders.get(serviceName)==null)
				    {
				    	topServicesByNumOfOrders.put(serviceName, numOfOrders);
				    }
				    else
				    {
				    	topServicesByNumOfOrders.put(serviceName, topServicesByNumOfOrders.get(serviceName)+numOfOrders);
				    }
			    }
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getTopServicesByName", e.toString());
		}
		return topServicesByNumOfOrders;
	}
	
	public static HashMap<String, Integer> getTopServicesByOrderValue()
	{
		HashMap<String, Integer> map = new HashMap<String, Integer>();
		try
		{
		    String sql = "SELECT services.service_name, SUM(orders.order_value) FROM orders INNER JOIN order_tracking_status ON order_tracking_status.order_id = orders.order_id INNER JOIN services ON services.service_id = orders.service_id GROUP BY orders.service_id;";
		    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
		    ResultSet rs = stmt.executeQuery();
		    while(rs.next())
		    {
		    	map.put(rs.getString(1), rs.getInt(2));
		    }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getTopServicesByOrderValue", e.toString());
		}
		return map;
	}
	
	public static List<String> getLoginStats()
	{
		List<String> list = new ArrayList<String>();
		try
		{
			LocalDate date = LocalDate.now();
			for(int i=37;i>=0;i--)
			{
				LocalDate pastDate = date.minusDays(i);
				String pastDateString = pastDate.toString();
			    String sql = "SELECT COUNT(user_id) FROM user_logs WHERE timestamp like \"%"+pastDateString+"%\" AND user_activity LIKE \"%Signed In%\";";
			    PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			    ResultSet rs = stmt.executeQuery();
			    while(rs.next())
			    {
			    	list.add(pastDateString+"#"+rs.getInt(1));
			    }
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AdminRepository.java", "getLoginStats", e.toString());
		}
		return list;
	}
	
}
