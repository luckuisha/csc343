import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {

	// A connection to the database
	Connection connection;

	// Can use if you wish: seat letters
	List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

	Assignment2() throws SQLException {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	//HELPER FUNCTIONS
	//Gets the id value that a new booking should use (current max id + 1)
	public int getNextBookingID() { 
		try {
			String queryString = "select max(booking.id) as nextid from booking";
			PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
			 rs = ps.executeQuery();
			if (rs.next()) {
				int nextID= rs.getInt("nextid");
				return (nextID+1);
					
					}			
			else{
				System.out.println("Something went wrong next booking id");
			}
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in getting next booking id");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return -1;		
		}
		return -1;
		
	}

	//Return true if passenger passID exists, false otherwise
	public boolean doesPassengerExist(int passID) {
	//Check if passenger exists
		try {
			String queryString = "select * from passenger where id=?";
			PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
			// Insert that int into the PreparedStatement and execute it.
			ps.setInt(1, passID);
			rs = ps.executeQuery();
			if (!rs.next()){
				System.out.println("PASSENGER NOT FOUND");
				return false;			 	
			}
			else
				return true;
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in flight search");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return false;
		}
	}

	//Return true if flight flightID exists, false otherwise
	public boolean doesFlightExist(int flightID) {
		try {
			String queryString = "select * from flight where id=?";
			PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
			// Insert that string into the PreparedStatement and execute it.
			ps.setInt(1, flightID);
			rs = ps.executeQuery();
		 
			if (!rs.next()){
				System.out.println("FLIGHT NOT FOUND");
				return false;	
			}
			else
				return true;		 	
			}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in flight search");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return false;
		}
	}

	//You get the point
	public boolean doesBookingExist(int passID, int flightID) {
		try {
			String queryString = "select * from booking where flight_id=? and pass_id=?";
			PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
			// Insert that string into the PreparedStatement and execute it.
			ps.setInt(1, flightID);
			ps.setInt(2, passID);
			rs = ps.executeQuery();
						 
			if (!rs.next()){
				System.out.println("BOOKING NOT FOUND");
				return false;	
			}
			else
				return true;
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in booking search");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return false;		
		}
	}

	//Attempts to remove the described booking. Will return true on success, false on failure
	public boolean removeBooking(int passID, int flightID, int bookID) {
		try {
			if (  !doesBookingExist(passID, flightID) )
				return false;
			
			String queryString = "delete from booking where id =?";
			PreparedStatement ps = connection.prepareStatement(queryString);
		 	// Insert that string into the PreparedStatement and execute it.
			ps.setInt(1, bookID);
		 	ps.executeUpdate();
		   }
		   
			catch (SQLException se) {
				System.out.println("SQL EXCEPTION in booking delete");
				System.err.println("<Message>: " + se.getMessage());
                se.printStackTrace();
				return false;		
			} 
			return true;
	}
	
	public String obtainFirstSeatUpgrade (int flightID, String seatClass){
        int firstRowOfSeatClass, firstRowOfNextSeatClass;
		int capacityCounter= getSeatClassCapacity(flightID, seatClass);
		firstRowOfSeatClass= getFirstRowOfSeatClass(flightID, seatClass);
		if (seatClass=="first")
			firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "business");
		else if (seatClass=="business")
			firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "economy");
		else {
			//This is economy class, so the upper bound of the for loop should be the last 
			int totalcapacity= getSeatClassCapacity(flightID, "economy")
				+ getSeatClassCapacity(flightID, "business")
				+ getSeatClassCapacity(flightID, "first");
			int fullRows= totalcapacity/6;
			int remainder= totalcapacity%6;
			if (remainder==0)
				firstRowOfNextSeatClass= fullRows+1;
			else
				firstRowOfNextSeatClass= fullRows+2;
			
		}

		//This for loop spans only the seats that are in this seatClass. 
		//seatLetters is declared at the top of this document, holds A-F in a list
		//Capacity counter prevents the loop from attempting to book non-existent seats on the last row 
		//(e.g. if last row only goes to 5C, the capacity counter should hit zero right after 5C)
		for (int i= firstRowOfSeatClass; i < firstRowOfNextSeatClass;  i++)	{
			for (int j=0; j< seatLetters.size() && capacityCounter!=0 ;j++) {
				if (  !isSeatOccupied(flightID, i, seatLetters.get(j) )  ) {
					return String.valueOf(i) + seatLetters.get(j);
				}
				capacityCounter--;
			}
		}
		return "youre a failure";
	}
    
    //update to upper class
    public boolean updateBooking(int passID, int flightID, int bookID , String seatClass) {
		try {
			if (!doesBookingExist(passID, flightID) )
				return false;
			
			String queryString = "update booking set seat_class=?::seat_class, " + 
                            "row=?, letter=? where pass_id=? and flight_id=? and id =?";
			PreparedStatement ps = connection.prepareStatement(queryString);
			String seat = obtainFirstSeatUpgrade (flightID, seatClass);
			int row = Integer.parseInt(seat.substring(0, 1));
			String seatLetter = seat.substring(1, 2);
		 	// Insert that string into the PreparedStatement and execute it.
		 	ps.setString(1, seatClass);
			ps.setInt(2, row);
			ps.setString(3, seatLetter);
			ps.setInt(4, passID);
			ps.setInt(5, flightID);
			ps.setInt(6, bookID);
		 	ps.executeUpdate();
		 	
		   }
		   
			catch (SQLException se) {
				System.out.println("SQL EXCEPTION in booking update in upgrade");
				System.err.println("<Message>: " + se.getMessage());
                se.printStackTrace();
				return false;		
			} 
			return true;
	}

	//True if seat (row, letter) on flight flightID is already booked. False otherwise
	public boolean isSeatOccupied (int flightID, int row, String letter) {
		try {
			String queryString = "select * from booking where flight_id=? and row=? and "+
										"letter=?";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
	 		// Insert that string into the PreparedStatement and execute it.
	 		ps.setInt(1, flightID);
	 		ps.setInt(2, row);
	 		ps.setString(3, letter);
			rs = ps.executeQuery();
					 
			if (!rs.next()){
				//Then result is empty, so seat is available
				return false;	
			}
			else
				return true;
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in checking seat occupation");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return false;		
		}
	}


	//Returns how many bookings already exist in seatClass on flightID.
	//If the result is greater than the capacity, that indicates overbooking (not handled in this function)
	public int currentSeatClassOccupation(int flightID, String seatClass) {
		try {
			String queryString = "select count(*) as num from booking where flight_id=? and "+
										"seat_class=?::seat_class";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
	 		// Insert that string into the PreparedStatement and execute it.
	 		ps.setInt(1, flightID);
	 		ps.setString(2, seatClass);       
	 
	 		rs = ps.executeQuery();
					 
			if (rs.next()){
				return rs.getInt("num");
			}
			else {
				System.out.println("Something went wrong current seat class occ");					 
			}
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in checking seat class occupation");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return -1;		
		}
		return -1;		
	}

	//Returns how many seats there are in seatClass on flightID
	public int getSeatClassCapacity(int flightID, String seatClass) {
		try {
			String queryString;		 
			if (!(seatClass=="economy" || seatClass=="business" || seatClass=="first")){
				System.out.println("INVALID SEAT CLASS");
				return -1;					 	
			}
					 
			queryString = "select capacity_" + seatClass + " as num from flight, plane " + 
							 "where flight.id=? and flight.plane= plane.tail_number";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
			
	 		ps.setInt(1, flightID);
	 		rs = ps.executeQuery();
			
			if (rs.next()){
				return rs.getInt("num");
			}
			else {
				System.out.println("Something went wrong get seat class cap");					 
			}
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in checking seat class occupation");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return -1;		
		}
		return -1;		
	}

	//Returns the price of a seatClass booking on flightID	
	public int getSeatClassPrice(int flightID, String seatClass) {
		try {
			String queryString;
			if (!(seatClass=="economy" || seatClass=="business" || seatClass=="first")){
				System.out.println("INVALID SEAT CLASS");
				return -1;					 	
			}
			queryString = "select " + seatClass + " as thisprice from price " + 
								"where flight_id=?";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;

	 		ps.setInt(1, flightID);
	 		rs = ps.executeQuery();
			 
			if (rs.next()){
				return rs.getInt("thisprice");
			}
			else {
				System.out.println("Something went wrong get seat class");			 
			}
		}		 		
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in checking seat class price");
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return -1;		
		}   
		return -1;		
	}


	//Returns the starting row of seatClass on flightID (e.g. if 3, then 3A, 3B,... is the beginning of that class)
	public int getFirstRowOfSeatClass(int flightID, String seatClass) {
		//Do the math for where seatClass would begin, 
		//by considering the rows taken up by the seat classes in front of them
		if (seatClass=="first")
			return 1;
		if (seatClass=="business") {
			//Corner case of having no first class. Waiting on Piazza question for this one
			if (getSeatClassCapacity(flightID, "first") == 0)
				return 1;
			int fullRowsUsedByFirst= (getSeatClassCapacity(flightID, "first"))/6;
			int remainder= (getSeatClassCapacity(flightID, "first"))%6;
			if (remainder==0)
				return fullRowsUsedByFirst+1;
			else
				return fullRowsUsedByFirst+2;
		}
		
		if (seatClass=="economy") {
			int businessFirstRow= getFirstRowOfSeatClass(flightID, "business");
			
			//Corner case of having no business class. Waiting on Piazza question for this one
			if (getSeatClassCapacity(flightID, "business") == 0) {
				return businessFirstRow;
			}
			else {
				int fullRowsUsedByBusiness= (getSeatClassCapacity(flightID, "business"))/6;
				int remainder= (getSeatClassCapacity(flightID, "business"))%6;
				if (remainder==0)
					return businessFirstRow + fullRowsUsedByBusiness;
				else
					return businessFirstRow + fullRowsUsedByBusiness + 1;
			}
		}

	return -1;
	}

	//Finds the first empty seat (going in the required order) in seatClass and attempts to book it
	//Does NOT attempt overbooking for economy class
	public boolean bookFirstEmptySeatInClass(int passID, int flightID, String seatClass) {
		int firstRowOfSeatClass, firstRowOfNextSeatClass;
		int capacityCounter= getSeatClassCapacity(flightID, seatClass);
		firstRowOfSeatClass= getFirstRowOfSeatClass(flightID, seatClass);
		if (seatClass=="first")
			firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "business");
		else if (seatClass=="business")
			firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "economy");
		else {
			//This is economy class, so the upper bound of the for loop should be the last 
			int fullRows= getSeatClassCapacity(flightID, "economy")/6;
			int remainder= getSeatClassCapacity(flightID, "economy")%6;
			if (remainder==0)
				firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "economy") + fullRows;
			else
				firstRowOfNextSeatClass= getFirstRowOfSeatClass(flightID, "economy") + fullRows +1;
			
		}
        System.out.println(firstRowOfNextSeatClass);
		//This for loop spans only the seats that are in this seatClass. 
		//seatLetters is declared at the top of this document, holds A-F in a list
		//Capacity counter prevents the loop from attempting to book non-existent seats on the last row 
		//(e.g. if last row only goes to 5C, the capacity counter should hit zero right after 5C)
		for (int i= firstRowOfSeatClass; i < firstRowOfNextSeatClass;  i++)	{
			for (int j=0; j< seatLetters.size() && capacityCounter!=0 ;j++) {
				if (  !isSeatOccupied(flightID, i, seatLetters.get(j) )  ) {
					return bookSeatHelper(passID, flightID, seatClass,i, seatLetters.get(j), getSeatClassPrice(flightID, seatClass));
				}
				capacityCounter--;
			}
		}
		return false;
	}


	//Runs the actual SQL query to book	
	public boolean bookSeatHelper(int passID, int flightID, String seatClass,int row, String letter, int price) {
		try {
			String queryString = "INSERT INTO booking VALUES (?,?,?,?,?,?::seat_class,?,?)";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
	 		// Insert that string into the PreparedStatement and execute it.
	 		ps.setInt(1, getNextBookingID());
	 		ps.setInt(2, passID);
	 		ps.setInt(3, flightID);
	 		ps.setTimestamp(4, getCurrentTimeStamp());
	 		ps.setInt(5, price);
	 		ps.setString(6, seatClass);
	 		if (row == -1 || letter=="NULL") {
	 		 ps.setNull(7, java.sql.Types.INTEGER);
	 		 ps.setNull(8, java.sql.Types.NULL);
	 		
	 		}
	 		else {
	 		ps.setInt(7, row);
	 		ps.setString(8, letter);
	 		}
		
	 		ps.executeUpdate();	
			//If there was no exception, I guess we can just assume it worked?
			return true;
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in booking seat " + row + " "+ letter+" on flight "+flightID);
			System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return false;		
		}		
	}

	//Calculates how many customers are currently overbooked in economy on flight flightID.
	public int getNumOverbookedCustomers(int flightID)	{
		int amountOverbooked= currentSeatClassOccupation(flightID, "economy") - getSeatClassCapacity(flightID, "economy");
		
		if (amountOverbooked<0)		
			System.out.println("WARNING: Checking for overbooked customers when not overbooked");
			
		return amountOverbooked;
	}

	public boolean attemptOverbook (int passID, int flightID) {
		if (getNumOverbookedCustomers(flightID)>= 10){
			System.out.println("COULD NOT OVERBOOK: overbooked slots already full");
			return false;		
		}
		//Can now assume there is still space to overbook
		//Not sure about whether these nulls will pass into the query of bookSeatHelper. Definitely look this up later
		return bookSeatHelper(passID, flightID, "economy", -1, "NULL", getSeatClassPrice(flightID, "economy"));
	}

	/**
	* Connects and sets the search path.
	*
	* Establishes a connection to be used for this session, assigning it to
	* the instance variable 'connection'.  In addition, sets the search
	* path to 'air_travel, public'.
	*
	* @param  url       the url for the database
	* @param  username  the username to connect to the database
	* @param  password  the password to connect to the database
	* @return           true if connecting is successful, false otherwise
	*/
	public boolean connectDB(String URL, String username, String password) {
		try{
			connection = DriverManager.getConnection(URL, username, password);
			String searchPathQuery= "SET SEARCH_PATH TO air_travel, public";
			PreparedStatement ps = connection.prepareStatement(searchPathQuery);
			ps.executeUpdate();
		}
		catch (SQLException se){
			System.err.println("SQL Exception." +
	 		"<Message>: " + se.getMessage());
	 		return false; 
		}
		return true;
	}

	/**
	* Closes the database connection.
	*
	* @return true if the closing was successful, false otherwise
	*/
	public boolean disconnectDB() {
		// Implement this method!
		if (connection!= null) {
			try {
				connection.close();      
			}
			catch (SQLException se){
                System.err.println("<Message>: " + se.getMessage());
                se.printStackTrace();
				return false;
			}
		}
		return true;
	}

	/* ======================= Airline-related methods ======================= */

	/**
	* Attempts to book a flight for a passenger in a particular seat class. 
	* Does so by inserting a row into the Booking table.
	*
	* Read handout for information on how seats are booked.
	* Returns false if seat can't be booked, or if passenger or flight cannot be found.
	*
	* 
	* @param  passID     id of the passenger
	* @param  flightID   id of the flight
	* @param  seatClass  the class of the seat (economy, business, or first) 
	* @return            true if the booking was successful, false otherwise. 
	*/
	public boolean bookSeat(int passID, int flightID, String seatClass) {
		ResultSet rs;
		int seatClassCapacity, seatClassOccupation;
			if (!doesPassengerExist(passID))
				return false;             
			if (!doesFlightExist(flightID))
				return false;
			//Now we can assume the flight and passenger both exist.
			//Now find get some information about the capacity and occupation
			seatClassCapacity= getSeatClassCapacity(flightID, seatClass);
			seatClassOccupation= currentSeatClassOccupation(flightID, seatClass);
			if (seatClassOccupation >= seatClassCapacity) {
				if (seatClass=="economy")
					return attemptOverbook(passID, flightID);      			
				else {
					System.out.println("COULD NOT BOOK: seat class "+seatClass+" is full");      					
					return false;
				}
			}
			//All edge cases handled. Now we just have a regular booking in a non-full, non-overbooked
			//seat class
			bookFirstEmptySeatInClass(passID, flightID, seatClass);

		return true;
	}

	/**
	* Attempts to upgrade overbooked economy passengers to business class
	* or first class (in that order until each seat class is filled).
	* Does so by altering the database records for the bookings such that the
	* seat and seat_class are updated if an upgrade can be processed.
	*
	* Upgrades should happen in order of earliest booking timestamp first.
	*
	* If economy passengers left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats), 
	* remove their bookings from the database.
	* 
	* @param  flightID  The flight to upgrade passengers in.
	* @return           the number of passengers upgraded, or -1 if an error occured.
	*/
	public int upgrade(int flightID) {
		try {
			String queryString = "select pass_id as overbookedPassengers, id as bookID from booking where flight_id=? and "+
                "row IS NULL ORDER BY datetime";
	 		PreparedStatement ps = connection.prepareStatement(queryString);
			ResultSet rs;
	 		int upgradeCount= 0;
	 		ps.setInt(1, flightID);
	 		int overbookedPassID;
            int bookID;
		
	 		rs = ps.executeQuery();
					 
			//rs should now hold all overbooked passengers
			while (rs.next()){
				overbookedPassID= rs.getInt("overbookedPassengers");
				bookID = rs.getInt("bookID");
				//See if we can upgrade them to business class
				if (currentSeatClassOccupation(flightID, "business") < getSeatClassCapacity( flightID, "business")){
					updateBooking(overbookedPassID, flightID, bookID, "business");
						
					upgradeCount++;
				}
				//If not then try first class
				else if (currentSeatClassOccupation(flightID, "first") < getSeatClassCapacity( flightID, "first")){
					updateBooking(overbookedPassID, flightID, bookID, "first");
                    
					upgradeCount++;
				}
				else {
                    System.out.println("youre super gey");
					//Cannot accommodate this or any other overbooked passenger. Remove them from booking and exit		 			
					removeBooking(overbookedPassID, flightID, bookID);
				}
			}
			return upgradeCount;
		}
		catch (SQLException se) {
			System.out.println("SQL EXCEPTION in upgrade");
            System.err.println("<Message>: " + se.getMessage());
	 		se.printStackTrace();
			return -1;		
		}   	
	//return -1;
	}
	/* ----------------------- Helper functions below  ------------------------- */

	// A helpful function for adding a timestamp to new bookings.
	// Example of setting a timestamp in a PreparedStatement:
	// ps.setTimestamp(1, getCurrentTimeStamp());

	/**
	* Returns a SQL Timestamp object of the current time.
	* 
	* @return           Timestamp of current time.
	*/
	private java.sql.Timestamp getCurrentTimeStamp() {
		java.util.Date now = new java.util.Date();
		return new java.sql.Timestamp(now.getTime());
	}


	// Add more helper functions below if desired.

	/* ----------------------- Main method below  ------------------------- */

	public static void main(String[] args) {
		// You can put testing code in here. It will not affect our autotester.

		try {
		Assignment2 a2= new Assignment2();
		// Setting Up connection
		String url = "jdbc:postgresql://localhost:5432/csc343h-kimkyu9";
		String username = "kimkyu9";
		boolean tryConnect= a2.connectDB(url, username, "");
         while(a2.bookSeat(6, 11, "economy")){
              a2.bookSeat(6, 11, "business");
              a2.bookSeat(6, 11, "first");
          }
		//a2.upgrade(11);
		//a2.updateBooking(6, 11, 49, "first");
		
		tryConnect= (a2.disconnectDB());
		}
		catch(SQLException se) {
			System.out.println("Exception hooo");
			}
	}

}
