package ie.ucd.serverjavafiles;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

// This class is used to send Emails, mainly used in our Contact.html POST form

public class SendMail {
    
    private static JavaMailSenderImpl mailSender;
    
    public SendMail() throws MessagingException {
    	// The default MailConfig is MailConfig.xml, set to whosthere.ucd@gmail.com to send and receive emails.
        ApplicationContext appContext = new ClassPathXmlApplicationContext("MailConfig.xml");
	JavaMailSenderImpl mailSender = (JavaMailSenderImpl) appContext.getBean("mailSender");
        this.mailSender = mailSender;
    }
    
    public void setMailSender(String bean) throws MessagingException {
    	// If one would like to change the default, they may create a new .xml file in the resources folder and use setMailSender with the file name as the String parameter
        ApplicationContext appContext = new ClassPathXmlApplicationContext(bean);
	JavaMailSenderImpl mailSender = (JavaMailSenderImpl) appContext.getBean("mailSender");
        this.mailSender = mailSender;
    }
    
    public JavaMailSenderImpl getMailSender() {
        return this.mailSender;
    }
    
    public static void mailSender(String Subject, String From, String Msg) throws MessagingException {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper mailMsg = new MimeMessageHelper(mimeMessage);
        // By Default, all emails are sent to our own Email Address, Whosthere.ucd@gmail.com. If we implement a registration confirmation system, a new parameter will be added for setTo.
        mailMsg.setTo("Whosthere.ucd@Gmail.com");
        mailMsg.setFrom(From);
        mailMsg.setSubject(Subject);
        mailMsg.setText(Msg);
        mailSender.send(mimeMessage);
    }
}
