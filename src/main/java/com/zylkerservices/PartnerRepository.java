package com.zylkerservices;


import java.io.IOException;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class PartnerRepository {
	
	
	public static List<Partner> getRelevantPartnersData(int serviceId, String serviceLocation, String searchText, String sortType)
	{
		List<Partner> relevantPartnersData = new ArrayList<Partner>();
		String sortTypeQuery = "partner_profile.number_of_orders_completed/partner_profile.number_of_orders_received asc";
		if(sortType.equals("Price Low to High"))
		    sortTypeQuery = "partner_services.service_charge asc";
		else if(sortType.equals("Price High to Low"))
			sortTypeQuery = "partner_services.service_charge desc";
		else if(sortType.equals("Rating Low to High"))
			sortTypeQuery = "partner_profile.average_rating asc";
		else if(sortType.equals("Rating High to Low"))
			sortTypeQuery = "partner_profile.average_rating desc";
		String fetchRelevantPartnersDataSql = "SELECT partner_profile.partner_name, partner_profile.partner_phno, partner_profile.average_rating, partner_services.service_charge, partner_profile.partner_id, partner_profile.partner_dp_url FROM partner_profile INNER JOIN partner_services ON partner_profile.partner_id = partner_services.partner_id AND partner_services.service_id = ? AND partner_services.service_location = ? AND partner_profile.partner_name LIKE \"%"+searchText+"%\" ORDER BY "+sortTypeQuery+";";             
		try
		{
		    PreparedStatement fetchRelevantPartnersDataStmt = Database.getConnection().prepareStatement(fetchRelevantPartnersDataSql);
			fetchRelevantPartnersDataStmt.setInt(1, serviceId);
			fetchRelevantPartnersDataStmt.setString(2, serviceLocation);
			ResultSet rs = fetchRelevantPartnersDataStmt.executeQuery();
			while (rs.next()) 
			{
				Partner partner = new Partner();
				partner.setPartner_name(rs.getString(1));
				partner.setPartner_phno(rs.getLong(2));
				partner.setAvg_rating(rs.getDouble(3));
				partner.setService_charge(rs.getInt(4));
				partner.setPartner_id(rs.getInt(5));
				partner.setPartner_dp_url(rs.getString(6));
				relevantPartnersData.add(partner);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getRelevantPartnersData", e.toString());
		}
		return relevantPartnersData;
	}
	
	public static String updateProfile(Partner partner, HttpServletRequest request, HttpServletResponse response)
	{
		try
		{
			String updatePartnerProfileSql = "INSERT INTO partner_profile(partner_id, govt_number, partner_name, partner_phno) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE govt_number=?, partner_name=?, partner_phno=?;";      
			PreparedStatement updatePartnerProfileStmt = Database.getConnection().prepareStatement(updatePartnerProfileSql);
			updatePartnerProfileStmt.setInt(1, partner.getPartner_id());
			updatePartnerProfileStmt.setString(2, partner.getGovt_number());
			updatePartnerProfileStmt.setString(3, partner.getPartner_name());
			updatePartnerProfileStmt.setLong(4, partner.getPartner_phno());
			updatePartnerProfileStmt.setString(5, partner.getGovt_number());
			updatePartnerProfileStmt.setString(6, partner.getPartner_name());
			updatePartnerProfileStmt.setLong(7, partner.getPartner_phno());
			int rowsAffected = updatePartnerProfileStmt.executeUpdate();
			System.out.println(updatePartnerProfileStmt);
			if(rowsAffected > 0)
			{
				Logs.addUserLog(partner.getPartner_id(), "Partner Profile Updated");
			    HttpSession session = request.getSession();
			    session.setAttribute("name", partner.getPartner_name()==null ? null : partner.getPartner_name().split(" ")[0]);
			    session.setAttribute("dp_url", partner.getPartner_dp_url()==null ? null : partner.getPartner_dp_url());
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
	
	public static Partner getPartnerProfileInfo(int user_id)
	{
		Partner partner = new Partner();
		partner.setPartner_id(user_id);
		try
		{
			String fetchPartnerProfileInfoSql = "SELECT partner_profile.govt_number, partner_profile.partner_name, partner_profile.partner_phno, user_credentials.email, partner_profile.partner_dp_url FROM partner_profile INNER JOIN user_credentials ON partner_profile.partner_id = user_credentials.user_id AND partner_profile.partner_id = ?;";
			PreparedStatement fetchPartnerProfileInfoStmt = Database.getConnection().prepareStatement(fetchPartnerProfileInfoSql);
			fetchPartnerProfileInfoStmt.setInt(1, user_id);
			ResultSet rs = fetchPartnerProfileInfoStmt.executeQuery();
			while(rs.next())
			{
				partner.setGovt_number(rs.getString(1));
				partner.setPartner_name(rs.getString(2));
				partner.setPartner_phno(rs.getLong(3));
				partner.setPartner_email(rs.getString(4));
				partner.setPartner_dp_url(rs.getString(5));
				System.out.println(rs.getString(5)); 
			}
			return partner;
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService", "getPartnerProfileInfo", e.toString());
		}
		return partner;
	}
	
	public static HashMap<String, Object> getCompletePartnerInfo(int user_id, String serviceName, String serviceLocation, int customer_id)
	{
		HashMap<String, Object> map = new HashMap<String, Object>();
		boolean customerFavouritePartner = false;
		map.put("partner_id", user_id);
		try
		{
			String fetchPartnerProfileInfoSql = "SELECT partner_profile.partner_name, partner_profile.partner_phno, user_credentials.email, partner_profile.average_rating, partner_profile.partner_verification, partner_services.service_charge, partner_services.service_image, user_credentials.email_verification FROM partner_profile INNER JOIN user_credentials ON partner_profile.partner_id = user_credentials.user_id INNER JOIN partner_services ON partner_profile.partner_id = partner_services.partner_id AND partner_profile.partner_id = ? AND partner_services.service_id = ? AND partner_services.service_location = ?;";
			PreparedStatement fetchPartnerProfileInfoStmt = Database.getConnection().prepareStatement(fetchPartnerProfileInfoSql);
			fetchPartnerProfileInfoStmt.setInt(1, user_id);
			int serviceId = getServiceId(serviceName);
			fetchPartnerProfileInfoStmt.setInt(2, serviceId);
			fetchPartnerProfileInfoStmt.setString(3, serviceLocation);
			ResultSet rs = fetchPartnerProfileInfoStmt.executeQuery();
			while(rs.next())
			{
				map.put("partner_name", rs.getString(1));
				map.put("partner_phno",rs.getLong(2));
				map.put("partner_email",rs.getString(3));
				map.put("partner_average_rating", rs.getDouble(4));
				map.put("partner_verification_status", rs.getBoolean(5));
				map.put("service_charge", rs.getInt(6));
				map.put("service_name", serviceName);
				map.put("service_location", serviceLocation);
				map.put("service_image", rs.getString(7));
				map.put("is_verified", rs.getBoolean(8));
				String isFavouritePartnerSql = "SELECT row_id FROM favourites WHERE customer_id = ? AND partner_id = ? AND service_name = ? AND service_location = ?";
				PreparedStatement isFavouritePartnerStmt = Database.getConnection().prepareStatement(isFavouritePartnerSql);
				isFavouritePartnerStmt.setInt(1, customer_id);
				isFavouritePartnerStmt.setInt(2, user_id);
				isFavouritePartnerStmt.setString(3, serviceName);
				isFavouritePartnerStmt.setString(4, serviceLocation);
				rs = isFavouritePartnerStmt.executeQuery();
				if(rs.next())
				{
					customerFavouritePartner = true;
				}
				map.put("favourite_partner", customerFavouritePartner);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("AccountService", "getCompletePartnerInfo", e.toString());
		}
		return map;
	}
	
	public static String partnerServiceUpdate(int partner_id,int service_id, int service_charge, String service_location, String service_image)
	{
		try
		{
			String checkIfSameServiceIsPresentSql = "SELECT row_id FROM partner_services WHERE partner_id = ? AND service_id = ? AND service_location = ?;";
			PreparedStatement checkIfSameServiceIsPresentStmt = Database.getConnection().prepareStatement(checkIfSameServiceIsPresentSql);
			checkIfSameServiceIsPresentStmt.setInt(1, partner_id);
			checkIfSameServiceIsPresentStmt.setInt(2, service_id);
			checkIfSameServiceIsPresentStmt.setString(3, service_location);
			ResultSet rs = checkIfSameServiceIsPresentStmt.executeQuery();
			boolean alreadyExists = false;
			String partnerServiceUpdateSql = "INSERT INTO partner_services(partner_id, service_id, service_charge, service_location, service_image) VALUES (?, ?, ?, ?, ?);";
			PreparedStatement partnerServiceUpdateStmt = null;
			while(rs.next())
			{
				alreadyExists = true;
				int row_id = rs.getInt(1);
			    partnerServiceUpdateSql = "UPDATE partner_services SET service_charge = ?, service_image = ? WHERE row_id = ?";
			    partnerServiceUpdateStmt = Database.getConnection().prepareStatement(partnerServiceUpdateSql);
			    partnerServiceUpdateStmt.setInt(1, service_charge);
			    partnerServiceUpdateStmt.setString(2, service_image);
			    partnerServiceUpdateStmt.setInt(3, row_id);
			    int rowsAffected = partnerServiceUpdateStmt.executeUpdate();
			    if(rowsAffected > 0)
			    {
			    	return "success";
			    }
			}
			if(!alreadyExists)
			{
				partnerServiceUpdateStmt = Database.getConnection().prepareStatement(partnerServiceUpdateSql);
				partnerServiceUpdateStmt.setInt(1, partner_id);
				partnerServiceUpdateStmt.setInt(2, service_id);
				partnerServiceUpdateStmt.setInt(3, service_charge);
				partnerServiceUpdateStmt.setString(4, service_location);
				partnerServiceUpdateStmt.setString(5, service_image);
				int rowsAffected = partnerServiceUpdateStmt.executeUpdate();
			    if(rowsAffected > 0)
			    {
			    	return "success";
			    }
			}
			return "failed";
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("partnerRepository.java", "addNewPartnerService", e.toString());
			return "serverError";
		}
	}
	
	public static String addPartnerToFavourites(int customer_id, int partner_id, String serviceName, String serviceLocation)
	{
		try
		{
		    String addToFavouritesCheckSql = "SELECT row_id FROM favourites WHERE customer_id = ? AND partner_id = ? AND service_name = ? AND service_location = ?";
		    PreparedStatement addToFavouritesCheckStmt = Database.getConnection().prepareStatement(addToFavouritesCheckSql);
		    boolean removedFromFavourites = false;
		    addToFavouritesCheckStmt.setInt(1, customer_id);
		    addToFavouritesCheckStmt.setInt(2, partner_id);
		    addToFavouritesCheckStmt.setString(3, serviceName);
		    addToFavouritesCheckStmt.setString(4, serviceLocation);
		    ResultSet rs = addToFavouritesCheckStmt.executeQuery();
		    if(rs.next())
		    {
			    String removeFromFavouritesSql = "DELETE FROM favourites WHERE partner_id = ? AND customer_id = ? AND service_name = ? AND service_location = ?";
			    PreparedStatement removeFromFavouritesStmt = Database.getConnection().prepareStatement(removeFromFavouritesSql);
			    removeFromFavouritesStmt.setInt(1, partner_id);
			    removeFromFavouritesStmt.setInt(2, customer_id);
			    removeFromFavouritesStmt.setString(3, serviceName);
			    removeFromFavouritesStmt.setString(4, serviceLocation);
			    removeFromFavouritesStmt.executeUpdate();
			    removedFromFavourites = true;
			    return "success";
		    }
		    if(!removedFromFavourites) // then add to favourites
		    {
			    String addToFavouritesSql = "INSERT INTO favourites(customer_id, partner_id, service_name, service_location) VALUES(?, ?, ?, ?)";
			    PreparedStatement addToFavouritesStmt = Database.getConnection().prepareStatement(addToFavouritesSql);
			    addToFavouritesStmt.setInt(1, customer_id);
			    addToFavouritesStmt.setInt(2, partner_id);
			    addToFavouritesStmt.setString(3, serviceName);
			    addToFavouritesStmt.setString(4, serviceLocation);
			    addToFavouritesStmt.executeUpdate();
			    return "success";
		    }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "addPartnerToFavourites", e.toString());
		}
		return "serverError";
	}
	
	public static List<HashMap<String, Object>> getAllCustomerViews(int partner_id, int numOfRecords)
	{
		List<HashMap<String, Object>> customerViews = new ArrayList<HashMap<String, Object>>();
		try
		{
		    String fetchViewedCustomersSql = "SELECT customer_profile.customer_name, customer_profile.customer_phno, profile_views.service_name, profile_views.service_location, profile_views.timestamp FROM customer_profile INNER JOIN profile_views ON customer_profile.customer_id = profile_views.customer_id AND profile_views.partner_id = ? order by profile_views.row_id desc LIMIT ?;";
		    PreparedStatement fetchViewedCustomersStmt = Database.getConnection().prepareStatement(fetchViewedCustomersSql);
		    fetchViewedCustomersStmt.setInt(1, partner_id);
		    fetchViewedCustomersStmt.setInt(2, numOfRecords);
		    ResultSet rs = fetchViewedCustomersStmt.executeQuery();
		    while(rs.next())
		    {
		    	HashMap<String, Object> viewedCustomerData = new HashMap<String, Object>();
		    	viewedCustomerData.put("customer_name", rs.getString(1));
		    	viewedCustomerData.put("customer_phno", rs.getLong(2));
		    	viewedCustomerData.put("searched_service_name", rs.getString(3));
		    	viewedCustomerData.put("searched_service_location", rs.getString(4));
		    	viewedCustomerData.put("timestamp", rs.getObject(5));
		    	customerViews.add(viewedCustomerData);
		    }  
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getAllCustomerViews", e.toString());
		}
		return customerViews;
	}
	
	public static List<String> fetchAllMyServices(int partner_id) throws SQLException
	{
		List<String> partnerServices = new ArrayList<String>();
		String partnerServicesSql = "SELECT service_id, service_location, service_charge FROM partner_services WHERE partner_id = ?";
		PreparedStatement partnerServicesStmt = Database.getConnection().prepareStatement(partnerServicesSql);
		partnerServicesStmt.setInt(1, partner_id);
		ResultSet rs = partnerServicesStmt.executeQuery();
		while(rs.next())
		{
			String record = getServiceName(rs.getInt(1))+"-"+rs.getString(2)+"-"+rs.getInt(3);
			partnerServices.add(record);
		}
		return partnerServices; 
	}
	
	public static void updateProfileViews(int customer_id, int partner_id, String serviceName, String serviceLocation)
	{
		try
		{
			String addViewCountSql = "INSERT INTO profile_views(customer_id, partner_id, service_name, service_location, seen, visibility) VALUES (?, ?, ?, ?, ?, ?)";         
			PreparedStatement addViewCountStmt = Database.getConnection().prepareStatement(addViewCountSql);
			addViewCountStmt.setInt(1, customer_id);
			addViewCountStmt.setInt(2, partner_id);
			addViewCountStmt.setString(3, serviceName);
			addViewCountStmt.setString(4, serviceLocation);
			addViewCountStmt.setBoolean(5, false);
			addViewCountStmt.setBoolean(6, false);
			addViewCountStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("SearchServie.java", "addViewCount", e.toString());
		}
	}
	
	public static int getTotalViewsCountForTheDay(int partner_id) 
	{
		int viewsCount = -1;
	    LocalDate date = LocalDate.now();
	    String formattedDate = "%"+date+"%";
		try
		{
		    String numberOfViewsTodaySql = "SELECT count(row_id) FROM profile_views WHERE partner_id = ? AND timestamp LIKE \""+formattedDate+"\"";
		    PreparedStatement numberOfViewsTodayStmt = Database.getConnection().prepareStatement(numberOfViewsTodaySql);
		    numberOfViewsTodayStmt.setInt(1, partner_id);
		    ResultSet rs = numberOfViewsTodayStmt.executeQuery();
		    while(rs.next())
		    {
		    	viewsCount = rs.getInt(1);
		    } 
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getTotalViewsCountForTheDay", e.toString());
		}
		return viewsCount;
	}
	
	public static void updteOrdersCount(int partnerId)
	{
		try
		{
			String updateOrdersCountSql = "UPDATE partner_profile SET number_of_orders_received = number_of_orders_received + 1 WHERE partner_id = ?;";
			PreparedStatement updateOrdersCountStmt = Database.getConnection().prepareStatement(updateOrdersCountSql);
			updateOrdersCountStmt.setInt(1, partnerId);
			updateOrdersCountStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "updateOrdersCount", e.toString());
		}
	}
	
	public static void updteOrdersAcceptedCount(int partnerId)
	{
		try
		{
			String updateOrdersAcceptedCountSql = "UPDATE partner_profile SET number_of_orders_completed = number_of_orders_completed + 1 WHERE partner_id = ?;";
			PreparedStatement updateOrdersAcceptedCountStmt = Database.getConnection().prepareStatement(updateOrdersAcceptedCountSql);
			updateOrdersAcceptedCountStmt.setInt(1, partnerId);
			updateOrdersAcceptedCountStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "updateOrdersCount", e.toString());
		}
	}
	
	public static int getTotalViewsCountForAllTime(int partner_id) 
	{
		int viewsCount = -1;
		try
		{
		    String numberOfViewsTodaySql = "SELECT count(row_id) FROM profile_views WHERE partner_id = ?";
		    PreparedStatement numberOfViewsTodayStmt = Database.getConnection().prepareStatement(numberOfViewsTodaySql);
		    numberOfViewsTodayStmt.setInt(1, partner_id);
		    ResultSet rs = numberOfViewsTodayStmt.executeQuery();
		    while(rs.next())
		    {
		    	viewsCount = rs.getInt(1);
		    } 
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getTotalViewsCountForAllTime", e.toString());
		}
		return viewsCount;
	}
	
	public static List<HashMap<String, Object>> getAllPartnerOrders(int partner_id, int limit, HttpServletRequest request)
	{
		List<HashMap<String, Object>> partnerOrders = new ArrayList<HashMap<String, Object>>();
		try
		{
			String ordersReceivedByPartnerSql = "SELECT orders.order_id, customer_profile.customer_name, customer_profile.customer_phno, orders.service_id, orders.service_location, orders.order_value, orders.order_created_date, order_tracking_status.order_status, order_tracking_status.timestamp, customer_profile.customer_id, partner_services.service_image FROM orders INNER JOIN customer_profile ON customer_profile.customer_id = orders.customer_id AND orders.partner_id = ? INNER JOIN order_tracking_status ON orders.order_id = order_tracking_status.order_id LEFT JOIN partner_services ON partner_services.partner_id = orders.partner_id AND partner_services.service_id = orders.service_id AND partner_services.service_location = orders.service_location ORDER BY orders.order_id DESC LIMIT ?;";
			PreparedStatement ordersReceivedByPartnerStmt = Database.getConnection().prepareStatement(ordersReceivedByPartnerSql);
			ordersReceivedByPartnerStmt.setInt(1, partner_id); 
			ordersReceivedByPartnerStmt.setInt(2, limit);
			ResultSet rs = ordersReceivedByPartnerStmt.executeQuery();
			while(rs.next())
			{
				HashMap<String, Object> orderData = new HashMap<String, Object>();
				orderData.put("order_id", rs.getInt(1));
				orderData.put("customer_name", rs.getString(2));
				orderData.put("customer_phno", rs.getLong(3));
				orderData.put("service_name", getServiceName(rs.getInt(4)));
				orderData.put("service_location", rs.getString(5));
				orderData.put("order_value", rs.getInt(6));
				Timestamp t = (Timestamp) rs.getObject(7);
				orderData.put("order_created", findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000));
				orderData.put("order_status", rs.getString(8));
				t = (Timestamp) rs.getObject(9);
				orderData.put("order_last_updated", findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000));
				orderData.put("customer_id", rs.getInt(10));
				double orderTotalCharges = rs.getInt(6) + OrderService.calculateExtraCharges(rs.getInt(6));
				orderData.put("order_total_charges", orderTotalCharges);
				orderData.put("partner_id", partner_id);
				orderData.put("service_image", rs.getString(11));
				partnerOrders.add(orderData);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getAllPartnerOrders", e.toString());
		}
		if(limit > partnerOrders.size())
		{
			request.setAttribute("reachedMaxRecords", true);
		}
		else
		{
			request.setAttribute("reachedMaxRecords", false);
		}
		return partnerOrders;
	}
	
	public static String addAmountToWallet(int customer_id, int amount)
	{
		try
		{ 
			String addAmountToWalletSql = "UPDATE customer_profile SET wallet_balance = wallet_balance + ? WHERE customer_id = ?";
			PreparedStatement addAmountToWalletStmt = Database.getConnection().prepareStatement(addAmountToWalletSql);
			addAmountToWalletStmt.setInt(1, amount);
			addAmountToWalletStmt.setInt(2, customer_id);
			int numOfRowsAffected = addAmountToWalletStmt.executeUpdate();
			if(numOfRowsAffected > 0)
			{
				return "success";
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "addAmountToWallet", e.toString());
		}
		return "failed";
	}
	
	public static String getTotalRevenueForTheDay(int partner_id) 
	{
		int revenue = -1;
		int orders = -1;
	    LocalDate date = LocalDate.now();
	    String formattedDate = "%"+date+"%";
		try
		{
		    String revenueTodaySql = "SELECT sum(orders.order_value), count(orders.order_id) FROM orders INNER JOIN order_tracking_status ON orders.order_id = order_tracking_status.order_id WHERE orders.partner_id = ? AND orders.order_created_date like \""+formattedDate+"\" AND order_tracking_status.order_status LIKE \"%accepted%\" ;";
		    PreparedStatement revenueTodayStmt = Database.getConnection().prepareStatement(revenueTodaySql);
		    revenueTodayStmt.setInt(1, partner_id);
		    System.out.println(revenueTodayStmt);
		    ResultSet rs = revenueTodayStmt.executeQuery();
		    while(rs.next())
		    {
		    	revenue = rs.getInt(1);
		    	orders = rs.getInt(2);
		    } 
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getTotalRevenueForTheDay", e.toString());
		}
		return revenue+"-"+orders;
	}
	
	public static HashMap<String, Object> getOrderReview(int orderId) 
	{
		HashMap<String, Object> rar = new HashMap<String, Object>();
		try
		{
			String orderReviewSql = "SELECT rating, review FROM ratings_and_reviews WHERE order_id = ?";
			PreparedStatement orderReviewStmt = Database.getConnection().prepareStatement(orderReviewSql);
			orderReviewStmt.setInt(1, orderId);
			ResultSet rs = orderReviewStmt.executeQuery();
			while(rs.next())
			{
				rar.put("rating", rs.getInt(1));
				rar.put("review", rs.getString(2));
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getOrderReview", e.toString());
		}
		return rar;
	}
	
	public static int getServiceCharge(int partnerId, int serviceId, String serviceLocation)
	{
		int serviceCharge = -1;
		try
		{
			String findServiceChargeSql = "SELECT service_charge FROM partner_services WHERE partner_id = ? AND service_id = ? AND service_location = ?";
			PreparedStatement findServiceChargeStmt = Database.getConnection().prepareStatement(findServiceChargeSql);
			findServiceChargeStmt.setInt(1, partnerId);
			findServiceChargeStmt.setInt(2, serviceId);
			findServiceChargeStmt.setString(3,serviceLocation);
			ResultSet rs = findServiceChargeStmt.executeQuery();
			while(rs.next())
			{
				serviceCharge = rs.getInt(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getServiceCharge", e.toString());
		}
		return serviceCharge;
	}
	
	public static int getServiceId(String serviceName)
	{
		try
		{
			int serviceId = -1;
			String findServiceIdSql = "SELECT service_id FROM services WHERE service_name = ?";
			PreparedStatement findServiceStmt = Database.getConnection().prepareStatement(findServiceIdSql);
			findServiceStmt.setString(1, serviceName);
			ResultSet rs = findServiceStmt.executeQuery();
			while(rs.next())
			{
				serviceId = rs.getInt(1);
			}
			return serviceId;
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("partnerRepository.java", "getServiceId", e.toString());
			return -1;
		}
	}
	
	public static String getServiceName(int serviceId)
	{
		String serviceName = "";
		try
		{
			String findServiceNameSql = "SELECT service_name FROM services WHERE service_id = ?";
			PreparedStatement findServiceNameStmt = Database.getConnection().prepareStatement(findServiceNameSql);
			findServiceNameStmt.setInt(1, serviceId);
			ResultSet rs = findServiceNameStmt.executeQuery();
			while(rs.next())
			{
				serviceName = rs.getString(1);
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("partnerRepository.java", "getServiceName", e.toString());
		}
		return serviceName;
	}
	
	public static List<String> availableServices()
	{
		List<String> availableServices = new ArrayList<String>();
		try
		{
		    String fetchAvailableServicesSql = "SELECT service_name FROM services order by service_name;";
		    PreparedStatement fetchAvailableServiceStmt = Database.getConnection().prepareStatement(fetchAvailableServicesSql);
		    ResultSet rs = fetchAvailableServiceStmt.executeQuery();
		    while(rs.next())
		    {
		    	availableServices.add(rs.getString(1));
		    }
		    return availableServices;
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "availableServices", e.toString());
		}
		return null;
	}
	
	public static List<String> availableLocations()
	{
		List<String> availableLocations = new ArrayList<String>();
		try
		{
		    String fetchAvailableLocationsSql = "SELECT service_location FROM locations order by service_location;";
		    PreparedStatement fetchAvailableLocationsStmt = Database.getConnection().prepareStatement(fetchAvailableLocationsSql);
		    ResultSet rs = fetchAvailableLocationsStmt.executeQuery();
		    while(rs.next())
		    {
		    	availableLocations.add(rs.getString(1));
		    }
		    return availableLocations;
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "availableLocations", e.toString());
		}
		return null;
	}
	
	public static String findBestTimeFormat(Long timeDiff)
	{
		if(timeDiff>=0 && timeDiff<12)
		{
			return "Just now";
		}
		else if(timeDiff>=12 && timeDiff<60)
		{
			return timeDiff+" seconds ago";
		}
		else if(timeDiff >= 60 && timeDiff < 3600)
		{
			int min = (int) (timeDiff/60);
			if(min==1)
				return min+" minute ago";
			return min+" minutes ago";
		}
		else if(timeDiff >= 3600 && timeDiff < 86400)
		{
			int hrs = (int) (timeDiff/3600);
			if(hrs==1)
				return hrs+" hour ago";
			return hrs+" hours ago";
		}
		else if(timeDiff>=86400 && timeDiff < 2678400)
		{
			int days = (int) (timeDiff/86400);
			if(days==1)
				return days+" day ago";
			return days+" days ago";
		}
		else
		{
			int months = (int) (timeDiff/2678400);
			if(months==1)
				return months+" month ago";
			return months+" months ago";
		}
	}
	
	public static void getSubscription(int partnerId, HttpServletResponse response) throws IOException
	{
		System.out.println("reached");
		try
		{
			String sql = "SELECT subscription_end_date FROM premium_partners WHERE partner_id = ?";
			PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			stmt.setInt(1, partnerId);
			ResultSet rs = stmt.executeQuery();
			if(rs.next())
			{
				System.out.println("already having subscription");
				LocalDate currSubscriptionEndDate = (LocalDate) rs.getObject(1);
				LocalDate date = LocalDate.now();
				if(currSubscriptionEndDate.compareTo(date)<0)
				{
				    sql = "UPDATE premium_partners SET subscription_start_date = ?, subscription_end_date = ? WHERE partner_id = ?";
				    stmt = Database.getConnection().prepareStatement(sql);
				    LocalDate endDate = date.plusDays(31);
				    stmt.setObject(1, date);
				    stmt.setObject(2, endDate);
				    int nora = stmt.executeUpdate();
				    if(nora > 0)
					    response.setStatus(202);
				}
				else
				{
					System.out.println("subscription not ended  yet");
				}
			}
			else
			{
				sql = "INSERT INTO premium_partners(partner_id, subscription_start_date, subscription_end_date) VALUES(?, ? ,?);";
				stmt = Database.getConnection().prepareStatement(sql);
				LocalDate date = LocalDate.now();
				LocalDate endDate = date.plusDays(31);
				stmt.setInt(1, partnerId);
				stmt.setObject(2, date);
				stmt.setObject(3, endDate);
				int nora = stmt.executeUpdate();
				if(nora > 0)
					response.setStatus(202);
			}
		}
		catch(Exception e)
		{
			response.sendError(401); 
			Logs.addDeveloperLog("PartnerRepository.java", "getSubscription", e.toString());  
		}
	}
	
	public static boolean checkSubscriptionStatus(int partnerId)
	{
		boolean subscriptionStatus = false; 
		try
		{ 
			String sql = "SELECT subscription_end_date FROM premium_partners WHERE partner_id = ?";
			PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			stmt.setInt(1, partnerId);
			ResultSet rs = stmt.executeQuery();
			while(rs.next())
			{
				Date endDate = (Date) rs.getObject(1);
				Date date = new Date(System.currentTimeMillis());
				if(endDate.compareTo(date)>0)
					subscriptionStatus = true;
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "checkSubscriptionStatus", e.toString());
		}
		return subscriptionStatus;
	}
	
	public static String getSubscriptionEndDate(int partnerId)
	{
		String endDate = "";
		try
		{ 
			String sql = "SELECT subscription_end_date FROM premium_partners WHERE partner_id = ?";
			PreparedStatement stmt = Database.getConnection().prepareStatement(sql);
			stmt.setInt(1, partnerId);
			ResultSet rs = stmt.executeQuery();
			while(rs.next())
			{
				Date date = (Date) rs.getObject(1);
				LocalDate DATE = date.toLocalDate();
				LocalDate today = LocalDate.now();
				long numOfDays = ChronoUnit.DAYS.between(today, DATE);
				if(numOfDays == 1)
					return "1 Day";
				else 
					return numOfDays+" Days";
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("PartnerRepository.java", "getSubscriptionEndDate", e.toString());
		}
		return endDate;
	}
	
	public static int findNearestAmount(double requiredAmount)
	{
		if(requiredAmount <= 100.0 && requiredAmount > 0.0)
			return 100;
		if(requiredAmount <= 200.0 && requiredAmount > 100.0)
			return 200;
		if(requiredAmount <= 500.0 && requiredAmount > 200.0)
			return 500;
		if(requiredAmount <= 1000.0 && requiredAmount > 500.0)
			return 1000;
		if(requiredAmount <= 2000.0 && requiredAmount > 1000.0)
			return 2000;
		return 10000;
	}
	
}
