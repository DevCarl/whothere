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
    
        @Autowired
        DataSource dataSource;
    	
        @RequestMapping(value = "/api/table", method = RequestMethod.GET)
        public String apiRequestTable(@RequestParam(value = "request", required=true) String request) throws Exception{
            Connection connection = dataSource.getConnection();
            SqlQueries query = new SqlQueries(connection);
            request = query.sqlGetAllJson(request);
            return request;
        }

	@RequestMapping(value = "/api/tablesearch", method = RequestMethod.GET)
        public String apiRequestTableSearch(@RequestParam Map<String,String> requestParams) throws Exception{
		String request = requestParams.get("request");
		String specific = requestParams.get("key");
            Connection connection = dataSource.getConnection();
            SqlQueries query = new SqlQueries(connection);
            request = query.sqlGetAllJsonObject(request, specific);
            return request;
        }
	
	@RequestMapping(value = "/api/data", method = RequestMethod.GET)
	public String apiRequestData(@RequestParam Map<String,String> requestParams) throws Exception{
		String request = requestParams.get("request");
		String specific = requestParams.get(request);
                String request2 = requestParams.get("request2");
                String specific2 = requestParams.get(request2);
                String[] group = {request, request2};
                String additional = "";
                Connection connection = dataSource.getConnection();
                SqlQueries query = new SqlQueries(connection);
                for (int i = 0; i < group.length; i++){
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
		return request;
	}
	
}
