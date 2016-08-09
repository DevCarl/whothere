package ie.ucd.serverjavafiles;

import org.mindrot.jbcrypt.BCrypt;

public class Registration {
    
    private String UserName;
    private String Password;
    private String Admin;
    private boolean AccountActive;
    private String GroundTruthAccessCode;
    private String RegistrationCode;
    
    public Registration() {
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
    
    public String passwordEncryptor(String Password){
        String pw_hash = BCrypt.hashpw(Password, BCrypt.gensalt());
        return pw_hash;
    }
    
}
