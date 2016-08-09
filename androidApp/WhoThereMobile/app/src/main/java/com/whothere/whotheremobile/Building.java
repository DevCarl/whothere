package com.whothere.whotheremobile;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Ophelie on 07/08/2016.
 */
public class Building {
    private String name;
    private List<Room> rooms;

    public Building(String name){
        this.name = name;
        rooms = new ArrayList<Room>();
    }

    public String getName(){
        return this.name;
    }

    public void addRoom(Room room){
        rooms.add(room);
    }

    public List<Room> getRooms(){
        return this.rooms;
    }
}
