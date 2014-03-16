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

@SuppressWarnings("serial")
public class HelloWorldServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		resp.setContentType("text/plain");
		resp.setCharacterEncoding("UTF-8");
	}
}
