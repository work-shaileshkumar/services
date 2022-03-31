package com.zylkerservices;

import java.io.IOException;
import java.util.HashMap;

import org.codehaus.jackson.map.ObjectMapper;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class WalletController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		RequestDispatcher rd = null;
		if(jwt.get("user_role").equals("customer"))
		{
			rd = request.getRequestDispatcher("/customer-wallet.jsp");
			rd.forward(request, response);
		}
		else if(jwt.get("user_role").equals("partner"))
		{
			rd = request.getRequestDispatcher("");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		ObjectMapper mapper = new ObjectMapper();
		HashMap<String, Object> jwt = UserRepository.fetchJWT(request);
		int user_id = (Integer) jwt.get("user_id");
		String action = Security.sanitize(request.getParameter("action"));
		switch(action)
		{
		    case "add_money_to_wallet":
				HashMap<String, Object> addMoneyMap = mapper.readValue(request.getReader(), HashMap.class);
				String csrf = (String) addMoneyMap.get("csrf");
		    	if(jwt.get("user_role").equals("customer") && jwt.get("csrf").equals(csrf))
		    	{
		    	    Integer amount = (Integer)addMoneyMap.get("amount"); 
		    	    WalletService.addMoneyToWallet(amount, user_id, response);
		    	}
			    break;
		    case "buy_premium":
		    	HashMap<String, Object> premiumMap = mapper.readValue(request.getReader(), HashMap.class);
		    	String csrf_premium = (String) premiumMap.get("csrf");
		    	int partner_id = (Integer) jwt.get("user_id");
		    	if(jwt.get("user_role").equals("partner") && jwt.get("csrf").equals(csrf_premium))
		    	{
		    		WalletService.getAmount(1000, partner_id, response);
		    	}
		    case "verify_payment":
		    	HashMap<String, Object> verifyPaymentMap = mapper.readValue(request.getReader(), HashMap.class);
		    	String csrf_verify = (String) verifyPaymentMap.get("csrf");
		    	if(jwt.get("csrf").equals(csrf_verify))
		    	{
		    		String orderId = (String) verifyPaymentMap.get("order_id");
		    		String paymentId = (String) verifyPaymentMap.get("payment_id");
		    		String signature = (String) verifyPaymentMap.get("signature");
		    		int amount = ((Integer) verifyPaymentMap.get("amount"))/100;
		    		WalletService.verifyPayment(orderId, paymentId, signature, amount, user_id, response); 
		    	}
		    	break;
		    case "add_to_premium":
		    	HashMap<String, Object> premiumPartner = mapper.readValue(request.getReader(), HashMap.class);
		    	int partnerId = (int) premiumPartner.get("partner_id");
		    	PartnerRepository.getSubscription(partnerId, response);
		    	break;
			default:
				response.sendRedirect("index.jsp");
				break;
		}
		
	}

}
