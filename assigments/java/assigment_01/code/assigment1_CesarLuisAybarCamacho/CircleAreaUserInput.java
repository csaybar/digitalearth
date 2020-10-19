/** Executable class to calculate the area of any circle*/ 
import java.util.Scanner;

public class CircleAreaUserInput {
    Double circle_area;
    // Create the constructor
    public CircleAreaUserInput() {
        // Scanner is class which permit us get user input
        Scanner scanner_obj = new Scanner(System.in);
        System.out.print("Enter the radius of the circle in meters: ");

        // Read user input
        String  radius_str = scanner_obj.nextLine();
                
        // Is radius_str non-numeric? 
        if (!isNumeric(radius_str)) {
            // Use the "throw" statement to throw an exception
            throw new IllegalArgumentException(
                "The radius enter is not an number!"
            );
        }

        // Is radius negative? 
        Double radius = Double.parseDouble(radius_str); 
        
        if (radius < 0) {
            // Use the "throw" statement to throw an exception            
            throw new IllegalArgumentException(
                "The radius enter is negative!"
            );
        }

        // Calculate the area of the circle        
        circle_area = Math.PI*radius*radius;
    }

    // Evaluate if string is a number with RegEx.
    private static boolean isNumeric(String str) {
        return str.matches("-?\\d+(\\.\\d+)?");  
    }

    public void print() {
        System.out.format(
            String.format(
                "The area of the circle is: %.4f m²\n", 
                this.circle_area
            )
        );
    }

    public static void main(String[] args) {
        CircleAreaUserInput circle_case = new CircleAreaUserInput();
        circle_case.print();
    }
}