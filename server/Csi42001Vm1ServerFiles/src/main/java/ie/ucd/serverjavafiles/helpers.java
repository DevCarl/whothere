package ie.ucd.serverjavafiles;

import java.io.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class helpers {
    
    public void activateScript(String type, String location, String name){
        String base = "src/main/resources_scripts/";
        String run = type + " " + base + location + "/" + name;
        try {
            Process p = Runtime.getRuntime().exec(run);
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            String line;
            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}
