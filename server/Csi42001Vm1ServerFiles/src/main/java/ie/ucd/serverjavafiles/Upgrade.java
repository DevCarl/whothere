package ie.ucd.serverjavafiles;

// This class is used in the admincontrol POST form to upgrade a user. It assists SqlQueries.java - sqlUpgradeUsers in changing a users status

public class Upgrade {
    
    private String UserName;
    private String Admin;
    
    public String getUserName() {
        return this.UserName;
    }
    
    public String getAdmin() {
        return this.Admin;
    }
    
    public void setUserName(String UserName) {
        this.UserName = UserName;
    }
    
    public void setAdmin(String Admin) {
        this.Admin = Admin;
    } 
}
