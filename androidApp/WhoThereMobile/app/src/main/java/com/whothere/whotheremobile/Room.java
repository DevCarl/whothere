package com.whothere.whotheremobile;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Created by jonni on 06/08/2016.
 */
public class Room {
    @JsonProperty("Building")
    private String building;
    @JsonProperty("Capacity")
    private int capacity;
    @JsonProperty("Room_id")
    private int roomId;
    @JsonProperty("Room_no")
    private String roomNo;

    public Room(){}

    public Room(String building, int capacity, int roomId, String roomNo) {
        this.building = building;
        this.capacity = capacity;
        this.roomId = roomId;
        this.roomNo = roomNo;
    }

    public String getBuilding() {
        return building;
    }

    public int getCapacity() {
        return capacity;
    }

    public int getRoomId() {
        return roomId;
    }

    public String getRoomNo() {
        return roomNo;
    }

}
