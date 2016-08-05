package ie.ucd.serverjavafiles;

import org.mindrot.jbcrypt.BCrypt;

public class Registration {
    
    private int UsersId;
    private String UserName;
    private String Password;
    private boolean Admin;
    private boolean AccountActive;
    private String GroundTruthAccessCode;
    
    public Registration(int id, String name, String Password, boolean Admin, boolean Active, String Ground) {
        this.UsersId = id;
        this.UserName = name;
        this.Admin = Admin;
        this.AccountActive = Active;
        this.GroundTruthAccessCode = Ground;
        this.Password = passwordEncryptor(Password);
    }
    
    public int getUsersId() {
        return this.UsersId;
    }
    
    public String getUserName() {
        return this.UserName;
    }
    
    public String getPassword() {
        return this.Password;
    }
    
    public boolean getAdmin() {
        return this.Admin;
    }
    
    public boolean getAccountActive() {
        return this.AccountActive;
    }
    
    public String getGroundTruthAccessCode() {
        return this.GroundTruthAccessCode;
    }
    
    public void setUsersId(int UsersId) {
        this.UsersId = UsersId;
    }
    
    public void setUserName(String UserName) {
        this.UserName = UserName;
    }
    
    public void setPassword(String Password) {
        this.Password = passwordEncryptor(Password);
    }
    
    public void setAdmin(boolean Admin) {
        this.Admin = Admin;
    }
    
    public void setAccountActive(boolean AccountActive) {
        this.AccountActive = AccountActive;
    }
    
    public void setGroundTruthAccessCode(String GroundTruthAccessCode) {
        this.GroundTruthAccessCode = GroundTruthAccessCode;
    }
    
    public String passwordEncryptor(String Password){
        String pw_hash = BCrypt.hashpw(Password, BCrypt.gensalt());
        return pw_hash;
    }
    
}
