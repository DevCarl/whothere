package ie.ucd.serverjavafiles;

import org.mindrot.jbcrypt.BCrypt;

// This class is used to hold values entered in the registration POST form. It assists SqlQueries.java - SqlSetUsers in registering users

public class Registration {
    
    private String UserName;
    private String Password;
    private String Admin;
    private boolean AccountActive;
    private String GroundTruthAccessCode;
    private String RegistrationCode;
    
    public Registration() {
        // This provides the default values for a new user. We have decided to set all new accounts as active, with no registration confirmation
        // This may be added in future, in which case the AccountActive variable would be set to false until email is confirmed.
        this.Admin = "ROLE_USER";
        this.AccountActive = true;
        this.GroundTruthAccessCode = "Test";
    }
    
    public String getUserName() {
        return this.UserName;
    }
    
    public String getPassword() {
        return this.Password;
    }
    
    public String getAdmin() {
        return this.Admin;
    }
    
    public boolean getAccountActive() {
        return this.AccountActive;
    }
    
    public String getGroundTruthAccessCode() {
        return this.GroundTruthAccessCode;
    }
    
    public String getRegistrationCode() {
        return this.RegistrationCode;
    }
    
    public void setUserName(String UserName) {
        this.UserName = UserName;
    }
    
    public void setPassword(String Password) {
        this.Password = passwordEncryptor(Password);
    }
    
    public void setAdmin(String Admin) {
        this.Admin = Admin;
    }
    
    public void setAccountActive(boolean AccountActive) {
        this.AccountActive = AccountActive;
    }
    
    public void setGroundTruthAccessCode(String GroundTruthAccessCode) {
        this.GroundTruthAccessCode = GroundTruthAccessCode;
    }
    
    public void setRegistrationCode(String RegistrationCode) {
        this.RegistrationCode = RegistrationCode;
    }
    
    // This line encrypts a password entered by a user. Currently, the default iterations for encryption is 10. To change this, add a number in BCrypt.gensalt().
    // EG: BCrypt.hashpw(Password, BCrypt.gensalt(20))
    public String passwordEncryptor(String Password){
        String pw_hash = BCrypt.hashpw(Password, BCrypt.gensalt());
        return pw_hash;
    }
    
}
