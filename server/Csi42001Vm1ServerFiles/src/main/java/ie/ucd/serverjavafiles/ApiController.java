package ie.ucd.serverjavafiles;

import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {
	
	@RequestMapping(value = "/api", method = RequestMethod.GET)
	public String apiRequest(@RequestParam Map<String,String> requestParams) throws Exception{
		String SearchMethod=requestParams.get("request");
		String SearchTerms=requestParams.get("james");
		DataSourceConnection connection = new DataSourceConnection();
		SearchMethod = connection.sqlGetAllJson(SearchMethod);
		return SearchMethod;
	}
	
}
