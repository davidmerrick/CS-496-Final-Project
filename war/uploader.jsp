<!DOCTYPE HTML>
<html>
  <head>
    <title>Kitty Photo Uploader</title>
    <!--<meta http-equiv="Content-Type" content="text/html; charset=utf-8">-->
  </head>
  <body>
 	<form action="uploader.jsp" enctype="multipart/form-data" method="post">
 		Kitty photo<br />
 		<input name="photo" type="file"><br />
 		Caption<input type="text" name="caption"><br />
 		<input type="submit" value="Submit Kitty!">
 	</form>
 	<br />
<%@ page import="java.util.*" %>
<%@ page import="javax.jdo.*" %>
<%@ page import="edu.oregonstate.mobilecloud.*" %>
<%
PersistenceManager pm = PMF.getPMF().getPersistenceManager();
try {
	Map<String, Object> data = Util.read(request);
	String caption = (String)data.get("caption");
	byte[] photo = (byte[])data.get("photo[]");
	String photoName = (String)data.get("photo");
	
	if(caption == null) caption = "";
	if(photo == null) photo = new byte[0];
	if(photoName == null) photoName = "";

	String errorMessage = null;

	if(photo.length > 0) {
		Item item = new Item();
		item.setPhoto(photo);
		item.setCaption(caption);
		item.setTimestamp();
		pm.makePersistent(item);
		caption = "";
	} else {
		//errorMessage = "Photo is empty";
	}
	if(errorMessage != null){
		out.write("Error: " + errorMessage);
	}
} finally {
	pm.close();
}
%>
	<br />
	<a href="gallery.jsp">Kitty Gallery</a>
	</body>
</html>