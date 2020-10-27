/** Implementation of Fibonnaci algorithm with memoization and recursion*/ 
package assigment1_CesarLuisAybarCamacho;

import java.util.Map;
import java.util.List;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;

public class Fibonnaci {
    int init_number;
    int results;
    
    /** Create the constructor of the class */
    public Fibonnaci() {     
        String init_message = "|Welcome to Fibonnaci generator with memoization|";
        int init_message_length = init_message.length();
        String simple_line = String.format("%s", "-".repeat(init_message_length));
        System.out.println(simple_line);
        System.out.println(init_message);
        System.out.println(simple_line);          
    }

    // 2. Create a map object
    // Hint: A map contains key:value pairs. A HashTable is a special table that
    //       doesn't maintain any order.
    private Map<Integer, Integer> memoization = new HashMap<>();
    
    /** Implementation of fibonnaci algorithm with memoization
    * 
    * @param n Integer. Index of interest of the Fibonnaci series
    * @return Specific Fibonnaci serie value.
    * @throws IllegalArgumentException if the {@code n} is negative.
    *
    */
    private int fibonnaci_algorithm(int n) {
        // 3.1 Is the number negative or non-integer? 
        if (n < 0) {         
            // Use the "throw" statement to throw an exception            
            throw new IllegalArgumentException(
                "The number enter is negative!"
            );
        }        

        if (n == 0 || n == 1) {            
            return n;
        }
        
        // 3.2 This query exist in our Map object?
        if (memoization.containsKey(n)) {            
            return memoization.get(n);
        } else {
            // Fibonnaci is easier to solve trough recursion rather than iteration!
            int fibb_number = fibonnaci_algorithm(n - 1) + fibonnaci_algorithm(n - 2);
            // Adding a key:value to our map object (memoize)
            memoization.put(n, fibb_number);
            return fibb_number; 
        }                        
    }
    
    /**  Pretty display of Fibonacci series
    * 
    * @param n Integer. Index of interest of the Fibonnaci series
    * @return Fibonnaci series.        
    *
    */    
    public void run(int n) {        
        List<Integer> fib_serie = new ArrayList<Integer>();
        // 4.1 Run "fibonnaci_algorithm" in a reverse loop to force to use memoization.
        for (int i = n - 1; i >= 0; i--) {        
            fib_serie.add(fibonnaci_algorithm(i));            
        }
        // 4.2 Reverse the order in a list
        Collections.reverse(fib_serie);

        // 4.3 Print results        
        System.out.println(String.format("fibonnaci.run(%s):", n) + fib_serie);
    }

    public static void main(String[] args) {
        Fibonnaci serie = new Fibonnaci();
        serie.run(20);
    }    
}