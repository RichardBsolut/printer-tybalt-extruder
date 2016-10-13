use <../../libs/bcad.scad>
x=0;
y=1;
z=2;

module arrow(size=10, headpart=0.4, line) {    
    yrot(90) {
        color("orange")
        down(size/2)
        union() {
            up(size*headpart/2) cylinder(d1=0, d2=size/2, h=size*headpart, center=true, $fn=18);
            up(size/2+size*headpart/2) cylinder(d=size/6, h=size*(1-headpart), center=true, $fn=18);
        }
        
        if(line!=undef) {
            color("black")
                cylinder(d=0.1,h=line,center=true);
        }
    }
}