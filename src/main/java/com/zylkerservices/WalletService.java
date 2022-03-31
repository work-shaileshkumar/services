package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.PreparedStatement;
import java.util.Dictionary;
import java.util.Hashtable;

import org.json.JSONObject;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;

import jakarta.servlet.http.HttpServletResponse;

public class WalletService {
	
	public static void addMoneyToWallet(int amount, int user_id, HttpServletResponse response) throws IOException
	{
		Customer customer = CustomerRepository.getCustomerProfileInfo(user_id);
		RazorpayClient razorpay;
    	try
    	{
			razorpay = new RazorpayClient("rzp_test_LzlZ0GK1HYalNh", "mQMkMXsGfjI8RiN2QPPMsaRA");
	    	JSONObject orderRequest = new JSONObject(); 
	    	amount = amount*100;
	    	orderRequest.put("amount", amount);  
	    	orderRequest.put("currency", "INR");  
	    	orderRequest.put("receipt", "order_rcpt");
	    	Dictionary notes = new Hashtable();  
	    	notes.put("phno", customer.getCustomer_phno());
	    	notes.put("email", customer.getCustomer_email());
	    	notes.put("name", customer.getCustomer_name());
	    	orderRequest.put("notes", notes);
	    	Order order = razorpay.Orders.create(orderRequest);
	        PrintWriter out = response.getWriter();
	        response.setContentType("application/json");
	        response.setCharacterEncoding("UTF-8");
	        out.print(order);
	        out.flush();
    	}
    	catch(RazorpayException e)
    	{
    		Logs.addDeveloperLog("WalletService.java", "addMoneyToWallet", e.toString());
    	}

	}
	
	public static void verifyPayment(String orderId, String paymentId, String signature, int amount, int user_id, HttpServletResponse response)
	{
		try
		{
			JSONObject options = new JSONObject();
	        options.put("razorpay_order_id", orderId);
	        options.put("razorpay_payment_id", paymentId);
	        options.put("razorpay_signature", signature);
	        boolean verificationSuccess = Utils.verifyPaymentSignature(options, "mQMkMXsGfjI8RiN2QPPMsaRA");
	        if(verificationSuccess)
	        {
		        String executionResult = PartnerRepository.addAmountToWallet(user_id, amount);
		        if(executionResult.equals("success"))
		        {
		        	WalletService.addTransaction(-1, user_id, user_id, amount, "added to wallet");
			        JSONObject jsonResponse = new JSONObject();
			        jsonResponse.put("verification",verificationSuccess ? "success" : "failed");
			        jsonResponse.put("amount_added", amount);
		            PrintWriter out = response.getWriter();
		            response.setContentType("application/json");
		            response.setCharacterEncoding("UTF-8");
		            out.print(jsonResponse);
		            out.flush();
		        }
	        }
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("WalletService.java", "verifyPayment", e.toString());
		}
	}
	
	public static int addTransaction(int orderId, int senderId, int receiverId, double amount, String message)
	{
		int nora = -1;
		try
		{
		    String transactionSql = "INSERT INTO transactions(order_id, sender_id, receiver_id, transaction_value, transaction_message) VALUES(?, ?, ?, ?, ?);";
	        PreparedStatement transactionStmt = Database.getConnection().prepareStatement(transactionSql);
	        transactionStmt.setInt(1, orderId);
	        transactionStmt.setInt(2, senderId);
	        transactionStmt.setInt(3, receiverId);
	        transactionStmt.setDouble(4, amount);
	        transactionStmt.setString(5, message);
	        nora = transactionStmt.executeUpdate();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("WalletService.java", "addTransaction", e.toString());
		}
		return nora;
	}
	
	public static void getAmount(int amount, int partnerId, HttpServletResponse response) throws IOException
	{
		Partner partner = PartnerRepository.getPartnerProfileInfo(partnerId);
		RazorpayClient razorpay;
    	try
    	{
			razorpay = new RazorpayClient("rzp_test_LzlZ0GK1HYalNh", "mQMkMXsGfjI8RiN2QPPMsaRA");
	    	JSONObject orderRequest = new JSONObject(); 
	    	amount = amount*100;
	    	orderRequest.put("amount", amount);  
	    	orderRequest.put("currency", "INR");  
	    	orderRequest.put("receipt", "order_rcpt");
	    	Dictionary notes = new Hashtable();  
	    	notes.put("phno", partner.getPartner_phno());
	    	notes.put("email", partner.getPartner_email());
	    	notes.put("name", partner.getPartner_name());
	    	orderRequest.put("notes", notes);
	    	Order order = razorpay.Orders.create(orderRequest);
	        PrintWriter out = response.getWriter();
	        response.setContentType("application/json");
	        response.setCharacterEncoding("UTF-8");
	        out.print(order);
	        out.flush();
    	}
    	catch(RazorpayException e)
    	{
    		Logs.addDeveloperLog("WalletService.java", "getAmount", e.toString());
    	}
	}
	
}



