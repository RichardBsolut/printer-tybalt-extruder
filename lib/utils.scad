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

module spring(w=10,h=20,turns=20) {
    linear_extrude(height=h,twist=360*turns)
    move(x=w/2)
        xrot(90)circle(d=1);
}

module washer() {
    color("silver")
    difference() {
        cylinder(d=8,h=1);
        cylinder(d=3.2,h=3,center=true);
    }
}

//http://www.thingiverse.com/thing:884966
module Profile2020(size=20, height=10) {
	linear_extrude(height=height) {
		union() {
			extrusion_profile_20x20_v_slot_part(size);
			rotate([0,0,90])  extrusion_profile_20x20_v_slot_part(size);
			rotate([0,0,180]) extrusion_profile_20x20_v_slot_part(size);
			rotate([0,0,270]) extrusion_profile_20x20_v_slot_part(size);
		}
	}
}

module extrusion_profile_20x20_v_slot_part(size=20) {
	d = 5;
	r = 1.5;
	s1 = 1.8;
	s2 = 2;
	s3 = 6;
	s4 = 6.2;
	s5 = 9.5;
	s6 = 10.6;
	s7 = 20;

	reSize = size/20; // Scalling

	k0 = 0;
	k1 = d*0.5*cos(45)*reSize;
	k2 = d*0.5*reSize;
	k3 = ( (s7*0.5-s3)-s1*0.5*sqrt(2) )*reSize;
	k4 = s4*0.5*reSize;
	k5 = ( s7*0.5-s3 )*reSize;
	k6 = s6*0.5*reSize;
	k7 = ( s6*0.5+s1*0.5*sqrt(2) )*reSize;
	k8 = ( s7*0.5-s2 )*reSize;
	k9 = s5*0.5*reSize;
	k10 = s7*0.5*reSize;
	k10_1 = k10-r*(1-cos(45))*reSize;
	k10_2 = k10-r*reSize;

	polygon(points=[
		[k1,k1],[k0,k2],[k0,k5],[k3,k5],
		[k6,k7],[k6,k8],[k4,k8],[k9,k10],
		[k10_2,k10],[k10_1,k10_1],
		[k10,k10_2],
		[k10,k9],[k8,k4],[k8,k6],[k7,k6],
		[k5,k3],[k5,k0],[k2,k0]
	]);
}

