package ie.ucd.serverjavafiles;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class SendMail {
    
    private static JavaMailSenderImpl mailSender;
    
    public SendMail() throws MessagingException {
        ApplicationContext appContext = new ClassPathXmlApplicationContext("MailConfig.xml");
	JavaMailSenderImpl mailSender = (JavaMailSenderImpl) appContext.getBean("mailSender");
        this.mailSender = mailSender;
    }
    
    public void setMailSender(String bean) throws MessagingException {
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
        mailMsg.setTo("Whosthere.ucd@Gmail.com");
        mailMsg.setFrom(From);
        mailMsg.setSubject(Subject);
        mailMsg.setText(Msg);
        mailSender.send(mimeMessage);
    }
}
