package ie.ucd.serverjavafiles;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
 

public class DataSourceConnection {
	
	private static Connection connection;
	
	public DataSourceConnection() throws SQLException{
		ApplicationContext appContext = new ClassPathXmlApplicationContext("beans.xml");
		DataSource dataSource = (DataSource) appContext.getBean("dataSource");
		this.connection = dataSource.getConnection();
	}
	
	public Connection getConnection() {
		return connection;
	}
	
	public void setConnection(String bean) throws Exception{
		ApplicationContext appContext = new ClassPathXmlApplicationContext(bean);
		DataSource dataSource = (DataSource) appContext.getBean("dataSource");
		this.connection = dataSource.getConnection();
	}
	
	public static String sqlGetAll(String SearchMethod) throws SQLException{
		String query = "";
		Statement statement = connection.createStatement();
		ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
		while (resultSet.next()) {
			String id = resultSet.getString("Room_id");
			
			query = query + id + "\n";
		}
		return query;
	}
	
	public static String sqlGetAllJson(String SearchMethod) throws SQLException{
		String query = "";
		Statement statement = connection.createStatement();
		ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
		ResultSetToJson convert = new ResultSetToJson();
		String result = convert.convertJsonArray(resultSet);
		return result;
	}

	public static String sqlGetAllJsonObject(String SearchMethod, String Key) throws SQLException{
		String query = "";
		Statement statement = connection.createStatement();
		ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
		ResultSetToJson convert = new ResultSetToJson();
		String result = convert.convertJsonObject(resultSet, Key);
		return result;
	}
        
        public static String sqlJson(String additional, String specific, String specific2) throws SQLException{
            String select = "SELECT R.Room_id, R.Room_no, R.Building, R.Floor_no, R.Campus, R.Room_active, R.Capacity, R.Plug_friendly, "
                    + "W.Date, W.Time, W.Associated_client_counts, "
                    + "G.Room_used, G.Percentage_room_full, G.No_of_people, G.Lecture, G.Tutorial, "
                    + "T.Time_period, T.No_expected_students, T.Double_module, T.Class_went_ahead, "
                    + "M.Module_code, M.Facilty, M.Course_level, M.Undergrad, M.Module_active, "
                    + "P.People_estimate, P.Min_people_estimate, P.Max_people_estimate, P.Logistic_occupancy, "
                    + "P.Model_type, P.Model_info";
            String from = " FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M, Processed_data P";
            String where = " WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date "
                            + "AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Module_Module_code = M.Module_code "
                            + "AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id "
                            + "AND P.Time_Table_Date = W.Date AND P.Time_table_Time_period = T.Time_period "
                            + "AND P.Time_table_Room_Room_id = T.Room_Room_id ";
            String sql = select.concat(from.concat(where.concat(additional)));
            System.out.println(sql);
            PreparedStatement question = connection.prepareStatement(sql);
            question.setString(1, specific);
            if (specific2 != null){
                question.setString(2, specific2);
            }
            ResultSet resultSet = question.executeQuery();    
            ResultSetToJson convert = new ResultSetToJson();
            String result = convert.convertJsonFull(resultSet);
            return result;
        }
        
        public static ResultSet sqlQuery(String sql) throws SQLException {
            PreparedStatement statement = connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery();
            return resultSet;
        }

        public static void sqlSetUsers(Registration register) throws SQLException {
            String sql = "INSERT INTO Users "
                    + "(User_name, Password, Admin, Acount_active, Ground_truth_access_code) "
                    + "VALUES(?, ?, ?, ?, ?)";
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.setString(1, register.getUserName());
            statement.setString(2, register.getPassword());
            statement.setBoolean(3, register.getAdmin());
            statement.setBoolean(4, register.getAccountActive());
            statement.setString(5, register.getGroundTruthAccessCode());
            statement.execute();
        }
    
    public void setGroundTruth(GroundTruthData groundTruth){
    	String sql = "INSERT INTO Ground_truth_data (Room_Room_id, Date, Time, Room_used, "
    				+ "Percentage_room_full, No_of_people) VALUES(?, ?, ?, ?, ?, ?)";
    	
    	try{
        	PreparedStatement statement = connection.prepareStatement(sql);
        	statement.setInt(1, groundTruth.getRoomId());
        	statement.setString(2, groundTruth.getDate());
        	statement.setString(3, groundTruth.getTime());
        	statement.setInt(4, groundTruth.isRoomUsed());
        	statement.setFloat(5, groundTruth.getPercentageRoomUsed());
        	statement.setInt(6, groundTruth.getOccupancy());
        	statement.execute();
    	}catch(SQLException e){
    		throw new RuntimeException(e);
    	}finally{
    		if (connection != null) {
    			try{
    				connection.close();
    			}catch(SQLException e){}
    		}
    	}
    }
}
