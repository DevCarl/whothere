package com.whothere.whotheremobile;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Created by Ophelie on 06/08/2016.
 */
public class GroundTruthData {
    private String accessCode;
    private String classroom;
    private int roomId;
    private int capacity;
    private int occupancy;
    private String date;
    private String time;

    public GroundTruthData(){}

    public GroundTruthData(String accessCode, int roomId, int capacity, String classroom,
                           String date, String time, int occupancy) {
        this.accessCode = accessCode;
        this.classroom = classroom;
        this.roomId = roomId;
        this.capacity = capacity;
        this.occupancy = occupancy;
        this.date = date;
        this.time = time;
    }

    public String getAccessCode() {
        return accessCode;
    }

    public void setAccessCode(String accessCode) {
        this.accessCode = accessCode;
    }

    public String getClassroom() {
        return classroom;
    }

    public void setRoom(String room) {
        this.classroom = room;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getOccupancy() {
        return occupancy;
    }

    public void setOccupancy(int occupancy) {
        this.occupancy = occupancy;
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
}
