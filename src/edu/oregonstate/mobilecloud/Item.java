package edu.oregonstate.mobilecloud;

import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Blob;

@PersistenceCapable
public class Item {

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Long id;
	
	@Persistent
	private Blob photo;
	
	@Persistent
	private String caption;
	
	@Persistent
	private Date timestamp;
	
	public Long getID(){
		return id;
	}
	
	public byte[] getPhoto(){
		return photo != null ? photo.getBytes() : new byte[0];
	}
	
	public void setPhoto(byte[] photo){
		this.photo = new Blob(photo != null ? photo : new byte[0]);
	}
	
	public String getCaption(){
		return caption;
	}
	
	public void setCaption(String caption){
		this.caption = caption;
	}
	
	public void setTimestamp(){
		this.timestamp = new Date();
	}
	
	public Date getTimestamp(){
		return this.timestamp;
	}
	
//	public void delete(){
//		this.timestamp = new Date();
//	}
	
	public static List<Item> loadItems(String key, PersistenceManager pm){
		if(key == null){
			Query query = pm.newQuery(Item.class); 
			return (List<Item>) query.execute();
		} else {
			Query query = pm.newQuery(Item.class, "id == :dd");
			return (List<Item>) query.execute(key);
		}
	}
}
