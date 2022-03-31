package com.zylkerservices;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletResponse;


public class Cors extends HttpFilter {
       
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        
		HttpServletResponse res = (HttpServletResponse)response;
		//res.addHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500"); 
		//res.addHeader("Access-Control-Allow-Methods", "POST");
		//res.addHeader("Access-Control-Allow-Credentials", "true");
		chain.doFilter(request, response);
	}
}
