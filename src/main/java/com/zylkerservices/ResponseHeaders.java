package com.zylkerservices;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class ResponseHeaders extends HttpFilter {
       
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
		
		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) res;
		response.addHeader("X-XSS-Protection", "1; mode=block");
		//response.addHeader("Content-Security-Policy", "script-src 'unsafe-inline' https://apis.google.com/ https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js https://checkout.razorpay.com/v1/checkout.js https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js https://www.gstatic.com/charts/loader.js");
		response.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
		response.addHeader("X-Frame-Options", "DENY");
		response.addHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
		response.addHeader("Access-Control-Allow-Methods", "POST");
		response.addHeader("Access-Control-Allow-Credentials", "true");
		chain.doFilter(req, res);
	}

}
