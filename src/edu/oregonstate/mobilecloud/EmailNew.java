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

@SuppressWarnings("serial")
public class EmailNew extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		PersistenceManager pm = PMF.getPMF().getPersistenceManager();
		try {
			resp.setContentType("text/plain");
			Query query = pm.newQuery(Item.class);
			query.setOrdering("timestamp asc");
			List<Item> items = (List<Item>) query.execute();
			JSONArray array = new JSONArray();
			for(Item item : items){
				Date timestamp = item.getTimestamp();
				resp.getWriter().println("Timpstamp is " + timestamp);
				Date now = new Date();
				long diff = now.getTime() - timestamp.getTime();
				long diffMinutes = diff / (60 * 1000) % 60;
				resp.getWriter().println("diffMinutes is " + diffMinutes);
				if(diffMinutes <= 30){
					resp.getWriter().println("Found a new image! E-mailing it now");
				} else {
					break;
				}
			}
		} finally {
			pm.close();
		}
	}
}
