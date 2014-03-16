package edu.oregonstate.mobilecloud;

import edu.oregonstate.mobilecloud.Item;

import java.io.IOException;

import javax.servlet.http.*;

import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;
import javax.jdo.Query;

import org.json.simple.*;

import java.util.*;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;


@SuppressWarnings("serial")
public class EmailNew extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		PersistenceManager pm = PMF.getPMF().getPersistenceManager();
		try {
			String msgBody = "Recent Collages:"; //Message body for the email 
			List<String> sendArray = new ArrayList<String>(); //Array of email addresses to send message to
			
			//Build a list of email addresses to send to AND new collages (in the last 30 min)
			resp.setContentType("text/plain");
			Query query = pm.newQuery(Item.class);
			query.setOrdering("timestamp asc");
			List<Item> items = (List<Item>) query.execute();
			JSONArray array = new JSONArray();
			for(Item item : items){
				Date timestamp = item.getTimestamp();
				Date now = new Date();
				long diff = now.getTime() - timestamp.getTime();
				long diffMinutes = diff / (60 * 1000) % 60;
				if(diffMinutes <= 30){
					//@todo: remove hardcoding of server name
					msgBody = msgBody + "\n" + "http://social-collage.appspot.com/viewimage.jsp?item=" + item.getID().toString();
				} 
				String email = item.getEmail();
				if(email != null && email != ""){
					//Don't add duplicates to the list
					if(!sendArray.contains(email)){
						sendArray.add(email);
					}
				}
			}
						
			//Send the e-mail
			Properties props = new Properties();
	        Session session = Session.getDefaultInstance(props, null);

	        try {
	        	int numRecipients = sendArray.size(); 
	        	if(numRecipients > 0){
		        	Message msg = new MimeMessage(session);
		            msg.setFrom(new InternetAddress("dmerricka@gmail.com", "David Merrick"));
		            
		            //Loop through the sendArray and add every address as recepients
		            for(String email_address : sendArray){
		            	msg.addRecipient(Message.RecipientType.TO,
		                             new InternetAddress(email_address, "SocialCollage User"));
		            }
		            msg.setSubject("Recent Collages Uploaded to SocialCollage");
		            msg.setText(msgBody);
		            Transport.send(msg);
		            
		            
		            if(numRecipients > 1){
		            	resp.getWriter().println("Sent out e-mails to " + numRecipients + " recipients");
		            } else {
		            	resp.getWriter().println("Sent out an e-mail to 1 recipient");
		            }
	        	} else {
	        		resp.getWriter().println("No e-mail addresses to send to.");
	        	}
	        } catch (AddressException e) {
	        	resp.getWriter().println("AddressException e");
	        } catch (MessagingException e) {
	        	resp.getWriter().println("MessagingException e");
	        }
		} finally {
			pm.close();
		}
	}
}
