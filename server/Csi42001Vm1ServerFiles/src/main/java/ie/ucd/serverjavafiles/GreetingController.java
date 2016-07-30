package ie.ucd.serverjavafiles;

import java.sql.SQLException;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class GreetingController {
	
	@RequestMapping(value="/index", method=RequestMethod.GET)
	public String indexPage(Model model) {
		return "index";
	}
	
	@RequestMapping(value="/", method=RequestMethod.GET)
	public String indexPageFromLocalhost(Model model) {
		return "index";
	}
	
	@RequestMapping(value="/upload", method=RequestMethod.GET)
	public String uploadPage(Model model) {
		return "upload";
	}

    @RequestMapping(value="/greeting", method=RequestMethod.GET)
    public String greetingForm(Model model) {
        model.addAttribute("testsearch", new Search());
        System.out.println("testsearch");
        return "greeting";
    }

    @RequestMapping(value="/greeting", method=RequestMethod.POST)
    public String greetingSubmit(@ModelAttribute Search search, Model model) throws SQLException {
    	DataSourceConnection test = new DataSourceConnection();
    	DataSourceConnection.sqlGetAll(search.getSearchMethod());
        model.addAttribute("dave2", search);
        System.out.println(search.getSearchMethod());
        System.out.println("dave2");
        return "result";
    }

	@RequestMapping(value="/main", method=RequestMethod.GET)
	public String mainPage(Model model) {
		return "main";
	}
	
	@RequestMapping(value="/header", method=RequestMethod.GET)
	public String headerPage(Model model) {
		return "header";
	}

	@RequestMapping(value="/nav_bar", method=RequestMethod.GET)
	public String navPage(Model model) {
		return "nav_bar";
	}

	@RequestMapping(value="/footer", method=RequestMethod.GET)
	public String footerPage(Model model) {
		return "footer";
	}
}
