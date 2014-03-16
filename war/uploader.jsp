<!DOCTYPE HTML>
<html>
  <head>
    <title>Collage Uploader</title>
    <!--<meta http-equiv="Content-Type" content="text/html; charset=utf-8">-->
  </head>
  <body>
 	<form action="uploader.jsp" enctype="multipart/form-data" method="post">
 		Collage<br />
 		<input name="photo" type="file"><br />
 		Your name<input type="text" name="caption"><br />
 		Your e-mail (optional, for receiving daily e-mails of new collages submitted by other users)<input type="text" name="email"><br />
 		<input type="submit" value="Submit Collage">
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
	String email = (String)data.get("email");
	byte[] photo = (byte[])data.get("photo[]");
	String photoName = (String)data.get("photo");
	
	if(caption == null) caption = "";
	if(email == null) email = "";
	if(photo == null) photo = new byte[0];
	if(photoName == null) photoName = "";

	if(photo.length > 0) {
		Item item = new Item();
		item.setPhoto(photo);
		item.setCaption(caption);
		item.setEmail(email);
		item.setTimestamp();
		pm.makePersistent(item);
		caption = "";
	}
} finally {
	pm.close();
}
%>
	<br />
	<a href="gallery.jsp">Collage Gallery</a>
	</body>
</html>
