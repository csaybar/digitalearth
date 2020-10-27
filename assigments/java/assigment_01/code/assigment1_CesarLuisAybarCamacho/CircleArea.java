/** Executable class to calculate the area of specific circle*/ 
package assigment1_CesarLuisAybarCamacho;
public class CircleArea {
    Double circle_radius;
    Double circle_area;

    // Create the constructor
    public CircleArea(Double radius) {   
        circle_radius = radius;
        circle_area = Math.PI*radius*radius;
    }
    
    // Print results in a pretty way!
    public void print () {        
        System.out.format(
            String.format(
                "The area of the circle is: %.4f units\n",
                 this.circle_area
            )
        );
    }
    
    public static void main(String[] args) {
        CircleArea circle = new CircleArea(4.0);
        circle.print();
    }
}
