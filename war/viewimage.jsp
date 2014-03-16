<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.jdo.*" %>
<%@ page import="edu.oregonstate.mobilecloud.*" %>
<%@ page import="javax.jdo.Query" %>
<%
	PersistenceManager pm = PMF.getPMF().getPersistenceManager();
	try{
		Query query = pm.newQuery(Item.class);
		query.setOrdering("id desc");

		//Get all the items
		List<Item> allItems = (List<Item>)query.execute();
    	
    	//Find our item by ID specified in request
    	Item myItem = pm.getObjectById(Item.class, Long.parseLong(request.getParameter("item"), 10));
    	
    	response.setContentType("image/jpeg");
    	byte[] imageBytes = myItem.getPhoto();
    	response.getOutputStream().write(imageBytes);
    	response.getOutputStream().flush();    	
	} finally {
		pm.close();
	}
%>