package edu.oregonstate.mobilecloud;

import java.io.ByteArrayOutputStream; 
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//For debugging
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.io.BufferedWriter;


import javax.servlet.http.HttpServletRequest;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.util.Streams;
import java.util.Date;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;


public class Util {
	public static String clean(String str){
		return str.replaceAll("<", "&lt;").replaceAll("'","&apos;").replaceAll("\"", "&quot;").replaceAll("\\\\", "").replaceAll("\r", " ").replaceAll("\n", " ");
	}
	
	public static void dumpRequestHeaders(HttpServletRequest request){
		System.out.println("Request Headers:");
	    System.out.println();
	    Enumeration names = request.getHeaderNames();
	    while (names.hasMoreElements()) {
	      String name = (String) names.nextElement();
	      Enumeration values = request.getHeaders(name);  // support multiple values
	      if (values != null) {
	        while (values.hasMoreElements()) {
	          String value = (String) values.nextElement();
	          System.out.println(name + ": " + value);
	        }
	      }
	    }
	}
	
	public static void dumpRequest(HttpServletRequest request){
		InputStream is = null;
		try {
			is = request.getInputStream();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		BufferedReader br = null;
		StringBuilder sb = new StringBuilder();
 
		String line;
		try {
 
			br = new BufferedReader(new InputStreamReader(is));
			while ((line = br.readLine()) != null) {
				System.out.println(line);
			}
 
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	public static Map<String, Object> read(HttpServletRequest request) {
		Map<String, Object> rv = new HashMap<String, Object>();
		
		if(ServletFileUpload.isMultipartContent(request)){
			try {
				ServletFileUpload upload = new ServletFileUpload();
				
				FileItemIterator iterator = upload.getItemIterator(request);
				
				while(iterator.hasNext()){
					FileItemStream item = iterator.next();
					InputStream stream = item.openStream();
					String name = item.getFieldName();
					
					if(item.isFormField()){
						String value = Streams.asString(stream);
						rv.put(name, value);
						@SuppressWarnings("unchecked")
						List<String> values = (List<String>) rv.get(name + "[]");
						if(values == null){
							values = new ArrayList<String>();
							rv.put(name + "[]", values);
						}
						values.add(value);
					} else {
						ByteArrayOutputStream bos = new ByteArrayOutputStream();
						
						int len;
						byte[] buffer = new byte[2048];
						while((len = stream.read(buffer, 0, buffer.length)) > 0){
							bos.write(buffer, 0, len);
						}
						rv.put(name, item.getName());
						rv.put(name + "[]", bos.toByteArray());
					}
				}
			} catch(Exception e){
				throw new IllegalArgumentException(e);
			}
		} else {
			@SuppressWarnings("rawtypes")
			Enumeration params = request.getParameterNames();
			while(params.hasMoreElements()){
				String key = params.nextElement().toString();
				String[] values = request.getParameterValues(key);
				if(values != null && values.length > 0){
					rv.put(key, values[0]);
				}
				rv.put(key + "[]", Arrays.asList(values));
			}
		}
		return rv;
	}
}
