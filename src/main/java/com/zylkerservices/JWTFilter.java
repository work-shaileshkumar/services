package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;

import org.codehaus.jackson.map.ObjectMapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class JWTFilter extends HttpFilter {
       
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException 
	{
		HttpServletRequest request = (HttpServletRequest)(req);
		HttpServletResponse response = (HttpServletResponse)(res);
		Cookie[] cookies = request.getCookies();
		String[] encryptedJWT = new String[2];
		if(cookies != null)
		{
			for(Cookie cookie:cookies) 
			{
				if(cookie.getName().equals("user_token"))
				{
					try 
					{
						encryptedJWT = cookie.getValue().split("\\.");
						String token = Security.decodeFromBase64(encryptedJWT[0]);
						String signature = Security.decodeFromBase64(encryptedJWT[1]);
						HashMap<String, Object> jwt_map = new ObjectMapper().readValue(token, HashMap.class);
					    if(Security.get_sha_256(token).equals(Security.decrypt(signature)) && (Long)jwt_map.get("exp") > System.currentTimeMillis())
					    {
					        request.setAttribute("jwt_verification", jwt_map);
					        chain.doFilter(request, response);
					    }
					}
					catch(Exception e)
					{
					    request.setAttribute("jwt_verification", null);
					}
				}
			}
		}
		else
		{
		    response.sendRedirect("invalidToken.jsp");
		}
	}

}
