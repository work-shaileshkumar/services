package com.zylkerservices;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.http.HttpServletResponse;

public class TransactionService {
	
	public static List<HashMap<String, Object>> getAllPartnerTransactions(int partnerId, HttpServletResponse response) {
		
		List<HashMap<String, Object>> partnerTransactions = new ArrayList<HashMap<String, Object>>();
		try
		{
		    String getPartnerTransactionsSql = "SELECT customer_profile.customer_name, customer_profile.customer_phno, transactions.transaction_value, transactions.transaction_message, orders.service_id, orders.service_location, transactions.transaction_time, orders.order_id FROM transactions INNER JOIN customer_profile ON customer_profile.customer_id = transactions.sender_id INNER JOIN orders ON orders.order_id = transactions.order_id WHERE transactions.receiver_id = ? ORDER BY transactions.row_id DESC;";
		    PreparedStatement getPartnerTransactionStmt = Database.getConnection().prepareStatement(getPartnerTransactionsSql);
		    getPartnerTransactionStmt.setInt(1, partnerId);
		    ResultSet rs = getPartnerTransactionStmt.executeQuery();
		    while(rs.next())
		    {
		    	HashMap<String, Object> partnerTransaction = new HashMap<String, Object>();
		    	partnerTransaction.put("customer_name", rs.getString(1));
		    	partnerTransaction.put("customer_phno", rs.getLong(2));
		    	partnerTransaction.put("transaction_value", rs.getDouble(3));
		    	partnerTransaction.put("transaction_message", rs.getString(4));
		    	partnerTransaction.put("service_name",PartnerRepository.getServiceName(rs.getInt(5)));
		    	partnerTransaction.put("service_location", rs.getString(6));
		    	Timestamp t = (Timestamp) rs.getObject(7);
		    	String bestTime = PartnerRepository.findBestTimeFormat((System.currentTimeMillis()-t.getTime())/1000);
		    	partnerTransaction.put("transaction_time", bestTime);
		    	partnerTransaction.put("order_id", rs.getInt(8));
		    	partnerTransactions.add(partnerTransaction);
		    }
		}
		catch(Exception e)
		{   
			Logs.addDeveloperLog("TransactionsService.java", "getPartnerOrders", e.toString());
		}
		return partnerTransactions;
	}
	
}
