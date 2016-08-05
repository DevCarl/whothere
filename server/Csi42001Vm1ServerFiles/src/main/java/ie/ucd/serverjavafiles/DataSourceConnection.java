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
		System.out.println(query);
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
        
        public static String sqlJson(String additional, String specific) throws SQLException{
            String select = "SELECT R.Room_id, R.Room_no, R.Buildling, R.Floor_no, R.Campus, R.Room_active, R.Capacity, R.Plug_friendly, "
                    + "W.Wifi_log_id, W.Date, W.Time, W.Associated_client_counts, "
                    + "G.Data_input_id, G.Room_used, G.Percentage_room_full, G.No_of_people, G.Lecture, G.Tutorial, "
                    + "T.Time_period, T.No_expected_students, T.Double_module, T.Class_went_ahead, "
                    + "M.Module_code, M.Facilty, M.Course_level, M.Undergrad, M.Module_active";
            String from = " FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M";
            String where = " WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date "
                            + "AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Module_Module_code = M.Module_code "
                            + "AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id ";
            String sql = select.concat(from.concat(where.concat(additional)));
            PreparedStatement question = connection.prepareStatement(sql);
            question.setString(1, specific);
            ResultSet resultSet = question.executeQuery();    
            ResultSetToJson convert = new ResultSetToJson();
            String result = convert.convertJsonFull(resultSet);
            return result;
        }

        public static Boolean setUsers(Registration register) throws SQLException {
            String sql = "INSERT INTO Users VALUES(?, ?, ?, ?, ?, ?)";
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.setInt(1, register.getUsersId());
            statement.setString(2, register.getUserName());
            statement.setString(3, register.getPassword());
            statement.setBoolean(4, register.getAdmin());
            statement.setBoolean(5, register.getAccountActive());
            statement.setString(6, register.getGroundTruthAccessCode());
            statement.execute();
            sql = "PRINT @@ROWCOUNT";
            statement = connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery();
            return resultSet.getBoolean(1);
        }
}
