package ie.ucd.serverjavafiles;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Connection;


public class ResultSetToJson {
	
	public static String convertJsonArray(ResultSet resultSet) throws SQLException, JSONException {
		JSONArray json = new JSONArray();
		ResultSetMetaData meta = resultSet.getMetaData();
		
		while (resultSet.next()) {
			int numberColumns = meta.getColumnCount();
			JSONObject row = new JSONObject();
			for (int i=1; i<numberColumns+1; i++){
				String name = meta.getColumnName(i);
				JSONPlacer(meta.getColumnType(i), resultSet, row, i, name);
			}
			json.put(row);
		}
		return json.toString();
	}
	
	public static String convertJsonObject(ResultSet resultSet, String Key) throws SQLException, JSONException {
		JSONObject json = new JSONObject();
		ResultSetMetaData meta = resultSet.getMetaData();
		
		while (resultSet.next()) {
			int numberColumns = meta.getColumnCount();
			JSONObject row = new JSONObject();
			String newKey = null;
			for (int i=1; i<numberColumns+1; i++){
				String name = meta.getColumnName(i);
                                JSONPlacer(meta.getColumnType(i), resultSet, row, i, name);
				if (name.equals(Key)){
					newKey = row.get(name).toString();
				}
			}
			if (!json.has(newKey)){
				json.put(newKey, new JSONArray());
				json.getJSONArray(newKey).put(row);
			} else {
				json.getJSONArray(newKey).put(row);
			}
		}
		return json.toString();
	}
        
        public static String convertJsonFull(ResultSet resultSet) throws SQLException, JSONException {
                JSONObject json = new JSONObject();
                json.put("Room_no", new JSONObject());
                ResultSetMetaData meta = resultSet.getMetaData();
                while (resultSet.next()) {
                    String room_no = resultSet.getString("Room_no");
                    String Date = resultSet.getDate("Date").toString();
                    String Time = resultSet.getTime("Time_period").toString();
                    String Minutes = resultSet.getTime("Time").toString();
                    String Module = resultSet.getString("Module_code");
                    if (!json.getJSONObject("Room_no").has(room_no)){
                        json.getJSONObject("Room_no").put(room_no, new JSONObject());
                        json.getJSONObject("Room_no").getJSONObject(room_no).put("Date", new JSONObject());
                    }
                    JSONObject roomJSONLocation = json.getJSONObject("Room_no").getJSONObject(room_no);
                    if (!roomJSONLocation.getJSONObject("Date").has(Date)){
                        roomJSONLocation.getJSONObject("Date").put(Date, new JSONObject());
                        roomJSONLocation.getJSONObject("Date").getJSONObject(Date).put("Timeslot", new JSONObject());
                    }
                    JSONObject timeslotJSONLocation = roomJSONLocation.getJSONObject("Date").getJSONObject(Date).getJSONObject("Timeslot");
                    if (!timeslotJSONLocation.has(Time)){
                        timeslotJSONLocation.put(Time, new JSONObject());
                        timeslotJSONLocation.getJSONObject(Time).put("Module", new JSONObject());
                        timeslotJSONLocation.getJSONObject(Time).put("Time", new JSONObject());
                    }
                    JSONObject moduleJSONLocation = timeslotJSONLocation.getJSONObject(Time).getJSONObject("Module");
                    JSONObject minuteJSONLocation = timeslotJSONLocation.getJSONObject(Time).getJSONObject("Time");
                    if (!moduleJSONLocation.has(Module)){
                        moduleJSONLocation.put(Module, new JSONObject());
                    }
                    if (!minuteJSONLocation.has(Minutes)){
                        minuteJSONLocation.put(Minutes, new JSONObject());
                    }
                    int numberColumns = meta.getColumnCount();
                    for (int i=1; i<numberColumns+1; i++){
                        String name = meta.getColumnLabel(i);
                        String table = meta.getTableName(i);
                        JSONObject location = new JSONObject();
                        if (!(name.equals("Date") || name.equals("Time") || name.equals("Room_no") || name.equals("Time_period"))){
                        switch (table){
                            case "Wifi_log":
                                location = minuteJSONLocation.getJSONObject(Minutes);     break;
                            case "Time_table":
                            case "Ground_truth_data":
                            case "Processed_data":
                                location = timeslotJSONLocation.getJSONObject(Time);      break;
                            case "Room":
                                location = roomJSONLocation;                              break;
                            case "Module":
                                location = moduleJSONLocation.getJSONObject(Module);      break;
                        }
                        JSONPlacer(meta.getColumnType(i), resultSet, location, i, name);
                        }
                        
                    }
                }
                return json.toString();
        }
        
        public static void JSONPlacer(int columnType, ResultSet resultSet, JSONObject location, int fetchvalue, String putname) throws SQLException, JSONException{         
            switch (columnType){
                            case java.sql.Types.ARRAY:
				location.put(putname, resultSet.getArray(fetchvalue));		break;
			    case java.sql.Types.BIGINT:
			    case java.sql.Types.TINYINT:
			    case java.sql.Types.SMALLINT:
			    case java.sql.Types.INTEGER:
			    	location.put(putname, resultSet.getInt(fetchvalue));			break;
			    case java.sql.Types.DOUBLE:
			    	location.put(putname, resultSet.getDouble(fetchvalue));		break;
			    case java.sql.Types.FLOAT:
			    	location.put(putname, resultSet.getFloat(fetchvalue));		break;
			    case java.sql.Types.VARCHAR:
			    	location.put(putname, resultSet.getString(fetchvalue));		break;
			    case java.sql.Types.NVARCHAR:
			    	location.put(putname, resultSet.getNString(fetchvalue));		break;
			    case java.sql.Types.BOOLEAN:
			    	location.put(putname,  resultSet.getBoolean(fetchvalue));		break;
			    case java.sql.Types.TIMESTAMP:
			    	location.put(putname, resultSet.getTimestamp(fetchvalue));            break;
			    case java.sql.Types.DATE:
			    	location.put(putname, resultSet.getDate(fetchvalue));			break;
			    default:
			    	location.put(putname, resultSet.getObject(fetchvalue));               break;
			}
            
        }
}

        
