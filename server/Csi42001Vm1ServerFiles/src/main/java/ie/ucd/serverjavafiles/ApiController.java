package ie.ucd.serverjavafiles;

import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.filter.CharacterEncodingFilter;
import java.sql.Connection;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;


@CrossOrigin
@RestController
public class ApiController {
    
    	// Autowired set up to connect to settings found in MvcConfig.Java for Database connections
        @Autowired
        DataSource dataSource;
    	
        @RequestMapping(value = "/api/table", method = RequestMethod.GET)
        public String apiRequestTable(@RequestParam(value = "request", required=true) String request) throws Exception{
            switch (request){
                case "Buildings":
                case "Ground_truth_data":
                case "Module":
                case "Processed_data":
                case "Room":
                case "Time_table":
                case "Wifi_log":
                    break;
                default:
                    request = null;
            }
            // Each connection must be established via getConnection
            // You may establish a new instance of the SqlQueries Class, with the connection as the parameter
            SqlQueries query = new SqlQueries(dataSource.getConnection());
            request = query.sqlGetAllJson(request);
            // Close the connection at the end of the RequestMapping, before the return is processed.
            query.closeConnections();
            return request;
        }
	
	// Multiple parameters are processed by the <String, String> mapping.
	@RequestMapping(value = "/api/tablesearch", method = RequestMethod.GET)
        public String apiRequestTableSearch(@RequestParam Map<String,String> requestParams) throws Exception{
            // To add more parameters, add a new variable and get the param from the URL where .get(Something) is the name in the URL
	    String request = requestParams.get("request");
	    String specific = requestParams.get("key");
	    switch (request){
                case "Buildings":
                case "Ground_truth_data":
                case "Module":
                case "Processed_data":
                case "Room":
                case "Time_table":
                case "Wifi_log":
                    break;
                default:
                    request = null;
            }
            SqlQueries query = new SqlQueries(dataSource.getConnection());
            request = query.sqlGetAllJsonObject(request, specific);
            query.closeConnections();
            return request;
        }
	
	@RequestMapping(value = "/api/data", method = RequestMethod.GET)
	public String apiRequestData(@RequestParam Map<String,String> requestParams) throws Exception{
		// By ordering the .get correctly, you can use the value of one parameter as the name of another. For example, get(request) is the value of .get("request")
		String request = requestParams.get("request");
		String specific = requestParams.get(request);
                String request2 = requestParams.get("request2");
                String specific2 = requestParams.get(request2);
                String[] group = {request, request2};
                String additional = "";
                SqlQueries query = new SqlQueries(dataSource.getConnection());
                for (int i = 0; i < group.length; i++){
                    // We use a switch statement to control what we allow as parameters
                    switch ((group[i] != null) ? group[i] : "Null"){
                        case "Date":
                            additional = additional + "AND W.Date = ? ";              break;
                        case "Week":
                            additional = additional + "AND WEEK(W.Date) = WEEK(?) ";  break;
                        case "Module":
                            additional = additional + "AND M.Module_code = ? ";       break;
                        case "Room_no":
                            additional = additional + "AND R.Room_no = ? ";           break;
                    }
                }
		request = query.sqlJson(additional, specific, specific2);
                query.closeConnections();
		return request;
	}
	
}
