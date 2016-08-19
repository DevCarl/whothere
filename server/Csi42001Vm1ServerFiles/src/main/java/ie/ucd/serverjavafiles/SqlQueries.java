/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ie.ucd.serverjavafiles;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import javax.sql.DataSource;

/**
 *
 * @author devin
 */
public class SqlQueries {
    
    private Connection connection;
    private PreparedStatement preparedStatement;
    
    public SqlQueries(Connection connection) throws SQLException {
        this.connection = connection;
    }
    
    // This method is used to change both this.sql and this.preparedStatement. It also closes any open preparedStatements.
    // It will only close down any active Prepared Statement if the prepared Statement is not equal to null and if the String on record for the PreparedStatement 
    public void modifyPreparedStatement(String sql) throws SQLException { 
        boolean modifyNeeded = false;
        if (preparedStatement == null){
            modifyNeeded = true;
        } else if (preparedStatement != null && !preparedStatement.toString().equals(sql)){
            modifyNeeded = true;
            preparedStatement.close();
        }
        if (modifyNeeded){
            preparedStatement = connection.prepareStatement(sql);
        }
    }
    
    // This method is used to fill a statement from an array of values.
    protected void fillStatement(PreparedStatement stmt, Object[] set) throws SQLException{
        // Check if the array has no values
        if (set != null){
            // Go through the array, setting the values contained into the prepared Statement's placeholders
            for (int i = 0; i < set.length; i++) {
                if (set[i] != null){
                    stmt.setObject(i+1, set[i]);
                } else {
                    stmt.setNull(i+1, Types.OTHER);
                }
            }
        }
    }
    
    // This method merely closes down any active preparedStatements/Connections
    public void closeConnections() throws SQLException {
        try {
            try {
                if (preparedStatement != null) preparedStatement.close();
            } catch (SQLException e1) {
                throw new RuntimeException(e1);
            } finally {
                if (connection != null) connection.close();
            }
        } catch (SQLException e2){
            throw new RuntimeException(e2);
        }
    }
        
    public String sqlGetAll(String SearchMethod) throws SQLException{
	String query = "";
	Statement statement = connection.createStatement();
	ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
	while (resultSet.next()) {
	    String id = resultSet.getString("Room_id");
	    query = query + id + "\n";
	}
	return query;
    }
	
    public String sqlGetAllJson(String SearchMethod) throws SQLException{
	String query = "";
	Statement statement = connection.createStatement();
	ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
	String result = ResultSetToJson.convertJsonArray(resultSet);
        return result;
    }

    public String sqlGetAllJsonObject(String SearchMethod, String Key) throws SQLException{
	String query = "";
	Statement statement = connection.createStatement();
	ResultSet resultSet = statement.executeQuery("SELECT * FROM " + SearchMethod);
	String result = ResultSetToJson.convertJsonObject(resultSet, Key);
        return result;
    }
    
    //This method is used to pull all relevant data for our API
    public String sqlJson(String additional, String specific, String specific2) throws SQLException{
        String select = "SELECT R.Room_id, R.Room_no, R.Building, R.Floor_no, R.Campus, R.Room_active, R.Capacity, R.Plug_friendly, "
                + "W.Date, W.Time, W.Associated_client_counts, "
                + "G.Room_used, G.Percentage_room_full, G.No_of_people, G.Lecture, G.Tutorial, "
                + "T.Time_period, T.No_expected_students, T.Double_module, T.Class_went_ahead, "
                + "M.Module_code, M.Facilty, M.Course_level, M.Undergrad, M.Module_active, "
                + "P.People_estimate, P.Min_people_estimate, P.Max_people_estimate, P.Logistic_occupancy, "
                + "P.Model_type, P.Model_info";
        String from = " FROM Room R, Time_table T, Module M, Processed_data P, Wifi_log W";
        String join = " LEFT JOIN Ground_truth_data G";
        String on = " ON W.Room_Room_id = G.Room_Room_id AND W.Date = G.Date AND HOUR(W.Time) = HOUR(G.Time)";
        String where = " WHERE W.Room_Room_id = R.Room_id "
                        + "AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Module_Module_code = M.Module_code "
                        + "AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id "
                        + "AND P.Time_Table_Date = W.Date AND P.Time_table_Time_period = T.Time_period "
                        + "AND P.Time_table_Room_Room_id = T.Room_Room_id ";
        String sql = select.concat(from.concat(join.concat(on.concat(where.concat(additional)))));
        System.out.println(sql);
        this.modifyPreparedStatement(sql);
        Object[] set = (specific2 == null) ? new Object[]{specific} : new Object[]{specific, specific2};
        this.fillStatement(preparedStatement, set);
        ResultSet resultSet = preparedStatement.executeQuery();
        String result = ResultSetToJson.convertJsonFull(resultSet);
        return result;
    }
    //This is a method to add new users into the database
    public boolean sqlSetUsers(Registration register) throws SQLException {
        //You declare your string you wish to query, including any sections you wish to prepare
        String sql = "INSERT INTO Users "
               + "(User_name, Password, Admin, Acount_active, Ground_truth_access_code) "
               + "VALUES(?, ?, ?, ?, ?)";
        //You call modifyPreparedStatement to check if this statement is already prepared, this is useful as it saves the need to recall existing prepared statements if you wish to do the same query
        this.modifyPreparedStatement(sql);
        //You declare your array containing the values you wish to fill into the placeholders in your sql string
        Object[] set = {register.getUserName(), register.getPassword(), register.getAdmin(), register.getAccountActive(), register.getGroundTruthAccessCode()};
        //You call fillStatement to fill the prepared statement with your array
        this.fillStatement(preparedStatement, set);
        //You may then execute the query
        int count = preparedStatement.executeUpdate();
	return count > 0;
    }

    public boolean sqlUpgradeUsers(Upgrade upgrade) throws SQLException {
        String sql = "UPDATE Users SET Admin = ? WHERE User_name = ?";
        this.modifyPreparedStatement(sql);
        Object[] set = {upgrade.getAdmin(), upgrade.getUserName()};
        this.fillStatement(preparedStatement, set);
        int count = preparedStatement.executeUpdate();
        return count > 0;
    }
        
    public boolean sqlCheckUserExists(String user) throws SQLException {
        String sql = "SELECT User_name FROM Users WHERE User_name = ?";
        this.modifyPreparedStatement(sql);
        Object[] set = {user};
        this.fillStatement(preparedStatement, set);
        ResultSet resultSet = preparedStatement.executeQuery();
        resultSet.last();
        return (resultSet.getRow() < 1);
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
