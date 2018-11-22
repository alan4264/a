import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
	PreparedStatement ps;
	String query;
	ResultSet rs;

	try {
	    connection = DriverManager.getConnection(url, username, password);
	    query = "SET SEARCH_PATH to parlgov;";
	    ps = connection.prepareStatement(query);
	    ps.executeUpdate();
	}
	catch (SQLException se)
	{	
	    System.err.println("SQL Exception." +
		 "<Message>: " + se.getMessage());
	    return false;
	}
        return true;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
	try {
	    connection.close();
	}
	catch (SQLException se) {
	    System.err.println("SQL Exception. " + 
		"<Message>: " + se.getMessage());
	    return false;
	}
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
	PreparedStatement ps;
	String query;
	ResultSet rs;
 	List<Integer> elections = new ArrayList<Integer>() ;
	List<Integer> cabinets = new ArrayList<Integer>();

	try {
	    query = "SELECT c.election_id, c.id AS cabinet_id " +
		    "FROM cabinet c, country y " +
		    "WHERE y.name = " + "'" + countryName + "'" +
			"and c.country_id = y.id " +
		    "ORDER BY c.start_date DESC;";
	    ps = connection.prepareStatement(query);
	    rs = ps.executeQuery();
	
	    while (rs.next()) {
	        int electionId = rs.getInt("election_id");
	        int cabinetId = rs.getInt("cabinet_id");
	        elections.add(electionId);
	        cabinets.add(cabinetId);	
	    }
	} 
	catch (SQLException se) {
	    System.err.println("SQL Exception. " +
		"<Message>: " + se.getMessage());
	}

	ElectionCabinetResult answer = 
	 	new ElectionCabinetResult(elections, cabinets);   

        return answer;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
	PreparedStatement ps;
	String query;
	ResultSet rs;

	String comp_str;
	List<Integer> answer = new ArrayList<Integer>();

	try {
	    query = "SELECT id, concat(description, comment) AS des_com " +
		    "FROM politician_president " +
		    "WHERE id = " + politicianName + ";";
	    ps = connection.prepareStatement(query);
	    rs = ps.executeQuery();
	    rs.next();
	    comp_str = rs.getString("des_com");	

	    query = "SELECT id, concat(description, comment) AS des_com " +
		    "FROM politician_president " +
		    "WHERE id <> " + politicianName + ";";
	    ps = connection.prepareStatement(query);
	    rs = ps.executeQuery();
	    while (rs.next()) {
	        int id = rs.getInt("id");
		String des_com = rs.getString("des_com");
		if (similarity(comp_str, des_com) >= threshold) {
			answer.add(id);
		}
	    }	
	}
	catch (SQLException se) {
	    System.err.println("SQL Exception. " +
		"<Message>: " + se.getMessage());
	}
	
        return answer;
    }

    public static void main(String[] args) throws ClassNotFoundException {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
	Assignment2 a = new Assignment2();  
	boolean tf;
	tf = a.connectDB("jdbc:postgresql://localhost:5432/csc343h-zhoufen7",
		"zhoufen7","");
	System.out.println(tf);

	ElectionCabinetResult r = a.electionSequence("Canada");
	System.out.println(r);
	
	List<Integer> p = a.findSimilarPoliticians(9, 0.0f);
	System.out.println(p); 

	tf = a.disconnectDB();
	System.out.println(tf);
    }

}

