package ie.ucd.serverjavafiles;

import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;
<<<<<<< HEAD
import org.springframework.web.filter.CharacterEncodingFilter;
=======
>>>>>>> 656e6824d0d61891a51da1becfe44e2ee508f515

@CrossOrigin
@RestController
public class ApiController {
<<<<<<< HEAD
    	
        @RequestMapping(value = "/api/table", method = RequestMethod.GET)
        public String apiRequestTable(@RequestParam(value = "request", required=true) String request) throws Exception{
=======
    
        @RequestMapping(value = "/api/table", method = RequestMethod.GET)
        public String apiRequest(@RequestParam(value = "request", required=true) String request) throws Exception{
>>>>>>> 656e6824d0d61891a51da1becfe44e2ee508f515
            DataSourceConnection connection = new DataSourceConnection();
            request = connection.sqlGetAllJson(request);
            return request;
        }
<<<<<<< HEAD

	@RequestMapping(value = "/api/tablesearch", method = RequestMethod.GET)
        public String apiRequestTableSearch(@RequestParam Map<String,String> requestParams) throws Exception{
		String request = requestParams.get("request");
		String specific = requestParams.get("key");
            DataSourceConnection connection = new DataSourceConnection();
            request = connection.sqlGetAllJsonObject(request, specific);
            return request;
        }
	
	@RequestMapping(value = "/api/data", method = RequestMethod.GET)
	public String apiRequestData(@RequestParam Map<String,String> requestParams) throws Exception{
=======
	
	@RequestMapping(value = "/api/data", method = RequestMethod.GET)
	public String apiRequest(@RequestParam Map<String,String> requestParams) throws Exception{
>>>>>>> 656e6824d0d61891a51da1becfe44e2ee508f515
		String request = requestParams.get("request");
		String specific = requestParams.get(request);
                String additional = "";
                DataSourceConnection connection = new DataSourceConnection();
                switch (request){
                    case "Date":
                        additional = "AND W.Date = ?";                  break;
                    case "Week":
                        additional = "AND WEEK(W.Date) = WEEK(?)";      break;
                    case "Module":
                        additional = "AND M.Module_code = ?";           break;
                    case "Room_id":
                        additional = "AND R.Room_id = ?";               break;
                }
		request = connection.sqlJson(additional, specific);
		return request;
	}
	
}
