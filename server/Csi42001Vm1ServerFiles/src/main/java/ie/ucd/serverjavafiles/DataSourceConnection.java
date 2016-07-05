package ie.ucd.serverjavafiles;

import java.sql.Connection;
import java.sql.ResultSet;
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
}