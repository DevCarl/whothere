package ie.ucd.serverjavafiles;

import java.sql.SQLException;
import javax.mail.MessagingException;

import java.sql.ResultSet;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class GreetingController {
	
//	@RequestMapping(value="/index", method=RequestMethod.GET)
//	public String indexPage(Model model) {
//		return "main";
//	}
	
	@RequestMapping(value="/", method=RequestMethod.GET)
	public String indexPageFromLocalhost(Model model) {
		return "main";
	}
	
//    @RequestMapping(value="/greeting", method=RequestMethod.GET)
//    public String greetingForm(Model model) {
//        model.addAttribute("testsearch", new Search());
//        System.out.println("testsearch");
//        return "greeting";
//    }

//    @RequestMapping(value="/greeting", method=RequestMethod.POST)
//    public String greetingSubmit(@ModelAttribute Search search, Model model) throws SQLException {
//    	DataSourceConnection test = new DataSourceConnection();
//    	DataSourceConnection.sqlGetAll(search.getSearchMethod());
//        model.addAttribute("dave2", search);
//        System.out.println(search.getSearchMethod());
//        System.out.println("dave2");
//        return "result";
//    }
        
        @RequestMapping(value="/registration", method=RequestMethod.GET)
        public String registrationPage(Model model){
            model.addAttribute("registerModel", new Registration());
            return "registration";
        }
        
        @RequestMapping(value="/registration", method=RequestMethod.POST)
        public String registrationPost(@ModelAttribute Registration register, Model model) throws SQLException {
            model.addAttribute("registerModel", new Registration());
            DataSourceConnection connection = new DataSourceConnection();
            if (register.getRegistrationCode().equals("TEST")){
                ResultSet rs = connection.sqlQuery("SELECT User_name FROM Users WHERE User_name = '" + register.getUserName() + "'");
                rs.last();
                if (rs.getRow() < 1){
                    connection.sqlSetUsers(register);
                    return "redirect: /login?newaccount";
                }
            }
            return "redirect: /registration?error";
        }

	@RequestMapping(value="/main", method=RequestMethod.GET)
	public String mainPage(Model model) {
            return "main";
	}
	
	@RequestMapping(value="/contact", method=RequestMethod.GET)
	public String contactPage(Model model) throws MessagingException {
            model.addAttribute("contactModel", new Email());
            return "contact";
	}
        
        @RequestMapping(value="/contact", method=RequestMethod.POST)
	public String contactPage(@ModelAttribute Email email, Model model) throws MessagingException {
            model.addAttribute("contactModel", new Email());
            SendMail mail = new SendMail();
            mail.mailSender(email.getName(), email.getEmail(), email.getMsg());
            return "contact";
	}
	
	@RequestMapping(value="/header", method=RequestMethod.GET)
	public String headerPage(Model model) {
		return "header";
	}

	@RequestMapping(value="/nav_bar", method=RequestMethod.GET)
	public String navPage(Model model) {
		return "nav_bar";
	}
	
	@RequestMapping(value="/admin_nav_bar", method=RequestMethod.GET)
	public String adminNavPage(Model model) {
		return "admin_nav_bar";
	}

	@RequestMapping(value="/footer", method=RequestMethod.GET)
	public String footerPage(Model model) {
		return "footer";
	}
}
