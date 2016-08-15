package ie.ucd.serverjavafiles;

import java.io.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class helpers {
    
    //activateScript has three inputs. type is the language you are using (python3, Rscript), location is the folder location, name is the file name
    public static String activateScript(String type, String location, String name){
        String base = "src/main/resources_scripts/";
        String run = type + " " + base + location + "/" + name;
        try {
            Process p = Runtime.getRuntime().exec(run);
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = null;
            while ((in.readLine()) != null) {
                line = in.readLine();
                System.out.println(line);
            }
            return line;
        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
    }
    
    //overloaded version, if you want parameters, include them as a single string as last parameter. Include quotation marks for strings.
    //example with 3 parameters, an int, a String and an int - "1, 'Dave', 2".
    public static String activateScript(String type, String location, String name, String param){
        String base = "src/main/resources_scripts/";
        String run = type + " " + base + location + "/" + name + " " + param;
        try {
            Process p = Runtime.getRuntime().exec(run);
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = null;
            while ((in.readLine()) != null) {
                line = in.readLine();
                System.out.println(line);
            }
            return line;
        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
    }
}
