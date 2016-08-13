package ie.ucd.serverjavafiles;

// This class assists SendMail.Java in the sending of emails.
// It is used to temporarily store values from the POST request.

public class Email {
    
    private String Name;
    private String Email;
    private String Msg;
    
    public String getName() {
        return this.Name;
    }
    
    public String getEmail() {
        return this.Email;
    }
    
    public String getMsg() {
        return this.Msg;
    }
    
    public void setName(String Name) {
        this.Name = Name;
    }
    
    public void setEmail(String Email) {
        this.Email = Email;
    }
    
    public void setMsg(String Msg) {
        this.Msg = Msg;
    }
    
    // This should be called once before sending the email to allow us to see who sent the message
    public void addEmailInMsg(String Msg) {
        this.Msg = Msg + "\n\nSent by: " + this.Email;
    }
}
