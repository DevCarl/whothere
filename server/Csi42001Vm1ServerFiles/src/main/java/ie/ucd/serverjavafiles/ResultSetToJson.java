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
				switch (meta.getColumnType(i)){
				case java.sql.Types.ARRAY:
					row.put(name, resultSet.getArray(name));		break;
			    case java.sql.Types.BIGINT:
			    case java.sql.Types.TINYINT:
			    case java.sql.Types.SMALLINT:
			    case java.sql.Types.INTEGER:
			    	row.put(name, resultSet.getInt(name));			break;
			    case java.sql.Types.DOUBLE:
			    	row.put(name, resultSet.getDouble(name));		break;
			    case java.sql.Types.FLOAT:
			    	row.put(name, resultSet.getFloat(name));		break;
			    case java.sql.Types.VARCHAR:
			    	row.put(name, resultSet.getString(name));		break;
			    case java.sql.Types.NVARCHAR:
			    	row.put(name, resultSet.getNString(name));		break;
			    case java.sql.Types.BOOLEAN:
			    	row.put(name,  resultSet.getBoolean(name));		break;
			    case java.sql.Types.TIMESTAMP:
			    	row.put(name, resultSet.getTimestamp(name));	break;
			    case java.sql.Types.DATE:
			    	row.put(name, resultSet.getDate(name));			break;
			    default:
			    	row.put(name, resultSet.getObject(name));    	break;
				}
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
				switch (meta.getColumnType(i)){
				case java.sql.Types.ARRAY:
					row.put(name, resultSet.getArray(name));		break;
			    case java.sql.Types.BIGINT:
			    case java.sql.Types.TINYINT:
			    case java.sql.Types.SMALLINT:
			    case java.sql.Types.INTEGER:
			    	row.put(name, resultSet.getInt(name));			break;
			    case java.sql.Types.DOUBLE:
			    	row.put(name, resultSet.getDouble(name));		break;
			    case java.sql.Types.FLOAT:
			    	row.put(name, resultSet.getFloat(name));		break;
			    case java.sql.Types.VARCHAR:
			    	row.put(name, resultSet.getString(name));		break;
			    case java.sql.Types.NVARCHAR:
			    	row.put(name, resultSet.getNString(name));		break;
			    case java.sql.Types.BOOLEAN:
			    	row.put(name,  resultSet.getBoolean(name));		break;
			    case java.sql.Types.TIMESTAMP:
			    	row.put(name, resultSet.getTimestamp(name));	break;
			    case java.sql.Types.DATE:
			    	row.put(name, resultSet.getDate(name));			break;
			    default:
			    	row.put(name, resultSet.getObject(name));    	break;
				}
				if (name.toString().equals(Key)){
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
}
