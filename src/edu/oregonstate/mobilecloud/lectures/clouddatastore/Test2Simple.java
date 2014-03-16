package edu.oregonstate.mobilecloud.lectures.clouddatastore;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable
public class Test2Simple {
	@PrimaryKey
	@Persistent
	private String title;

	public String getTitle() {
		return title != null ? title : "";
	}
	public void setTitle(String title) {
		this.title = title;
	}
}