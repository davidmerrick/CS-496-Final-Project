<%@ page import="java.util.*" %>
<%@ page import="javax.jdo.*" %>
<%@ page import="org.json.simple.*" %>
<%@ page import="edu.oregonstate.mobilecloud.*" %>
<%
	PersistenceManager pm = PMF.getPMF().getPersistenceManager();
	try{
		List<Item> items = Item.loadItems(null, pm);
		JSONArray array = new JSONArray();
		for(Item item : items){
			JSONObject object = new JSONObject();
			object.put("id", item.getID());
			object.put("caption", item.getCaption());
			array.add(object);
		}
		out.write(array.toString());
	} finally {
		pm.close();
	}

%>