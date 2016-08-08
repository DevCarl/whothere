package ie.ucd.serverjavafiles;

public class GroundTruthData {
	private int roomId;
	private int capacity;
	private String classroom;
	private String date;
	private String time;
	private int occupancy;
	
	public GroundTruthData(){
	}
	
	public GroundTruthData(int roomId, int capacity, String classroom, 
			String date, String time, int occupancy){
		this.roomId = roomId;
		this.capacity = capacity;
		this.classroom = classroom;
		this.date = date;
		this.time = time;
		this.occupancy = occupancy;
	}

	public int getRoomId() {
		return roomId;
	}

	public void setBuilding(int roomId) {
		this.roomId = roomId;
	}

	public String getClassroom() {
		return classroom;
	}

	public void setClassroom(String classroom) {
		this.classroom = classroom;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public void setRoomId(int roomId) {
		this.roomId = roomId;
	}

	public int getOccupancy() {
		return occupancy;
	}

	public void setOccupancy(int occupancy) {
		this.occupancy = occupancy;
	}
	
	public int getCapacity() {
		return capacity;
	}

	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}

	public int isRoomUsed(){
		if(getOccupancy() > 0)
			return 1;
		else
			return 0;
	}
	
	public float getPercentageRoomUsed(){
		return (float)getOccupancy() / getCapacity();
	}
}
