use <../libs/bcad.scad>
use <../libs/screw.scad>
use <../libs/bearing.scad>
use <../libs/parts/motor/17HD.scad>
use <./lib/gears.scad>
include <./cfg.scad>
include <./lib/utils.scad>

layer_height = 0.25;

//Base cfg
nut_slop = 0.3;

m3_diameter = 3 + nut_slop;

m5_diameter = 5 + nut_slop;
m5_bolt_head_height = 4;
m5_nut_diameter = 7.85/cos(30)+nut_slop;

moving_clearance = 0.5;
fit_clearance = 0.25;

//Gear Abstract

gear_modulus = 1;
gear_pressure_angle = 22;
gear_depth_ratio = .5;
gear_clearance = .3;

module gearPattern(teeth) {
    gear2D(teeth, gear_modulus, gear_pressure_angle, gear_depth_ratio,  gear_clearance);
}

module gear(teeth,h) {
    linear_extrude(height=h, convexity=8)
        gearPattern(teeth);
}

function gearOuterRadius(teeth) =
    gear_outer_radius(teeth, gear_modulus, gear_depth_ratio, gear_clearance);

function gearHubSize(teeth) =
    gear_hub_size(teeth, gear_modulus, gear_depth_ratio, gear_clearance);

function gearPitchRadius(teeth) =
    gear_pitch_radius(teeth, gear_modulus);



//=== Config ===

num_plantes = 3;
ring_teeth = 36;
planet_teeth = 12;
bearing = 115;

sun_teeth = ring_teeth-planet_teeth*2;

sun_gear_hub_height = 6; // -3 we need to add madenschrauben
sun_gear_thread_height = 6;
sun_gear_hub_radius = gearOuterRadius(sun_teeth);
sun_gear_origin = [0, 0, 4];


planet_carrier_bottom_plate_height = 2;
planet_carrier_top_plate_height = m5_bolt_head_height+1;
planet_gear_thread_height = sun_gear_thread_height-1;


//=== Config extruder ===
//Hobbed Pulley
HPulleyD = 12;
HPulleyH = 14;
HPulleyHD = 1.5;  //Hobbed deepth
HPulleyHT = 12; //Hobbed center from bottom



//=== Calced
orbit_radius=((planet_teeth+sun_teeth)*gear_modulus)/2;
planet_carrier_height = planet_carrier_bottom_plate_height + planet_gear_thread_height + moving_clearance + planet_carrier_top_plate_height;


echo("planet_carrier_height",planet_carrier_top_plate_height);
planet_carrier_radius = gear_pitch_radius(ring_teeth, gear_modulus)-2;


//Sizeing
base_wall = 2;
base_size = [motorSize,motorSize,5]; //5-2 == 3mm space for motor brim
annulus_size = [base_size[x], base_size[y],moving_clearance+planet_carrier_bottom_plate_height+moving_clearance+planet_gear_thread_height];

cover_wall = 1+fit_clearance;
cover_size = [base_size[x], base_size[y], moving_clearance+planet_carrier_height-annulus_size[z]+get_bearing_height(bearing)+cover_wall];


//More console info
echo(str("sun_teeth: ", sun_teeth, ", ring_teeth: ", ring_teeth, ", planet_teeth: ", planet_teeth));
echo(str("gear ratio: ", ring_teeth+sun_teeth, " to ", sun_teeth, " (", 1+ring_teeth/sun_teeth, ":1)"));
echo("sun gear outer", gearOuterRadius(sun_teeth)*2,
    " hub ", gearHubSize(sun_teeth)*2);
echo("planet gear", gearOuterRadius(planet_teeth)*2);
echo("carrier height", planet_carrier_height);
echo("cover size", cover_size[z]);
echo("Full Height", base_size[z]+annulus_size[z]+cover_size[z]+11);//11==extruderCover

//extruderAssembly();
//$fn=50;
//!cover();

module plug() {
    cylinder(d=12,h=1.5);
    cylinder(d=8-fit_clearance,h=11+1.5);
}

module extruderAssembly() {
    17HD(center=true);
    basePlate();
    move(z=1.5)zrot(15) sunGear();
    
    
    %move(x=-motorScrewSpacing/2,y=-motorScrewSpacing/2-5,z=40-6)
        screw(screwlen=40);

    %move(x=motorScrewSpacing/2,y=motorScrewSpacing/2+5,z=30-6)
        screw(screwlen=30);

    
    move(z=base_size[z]+0.25) {
        /*zrot(60) {
            planetCarrierLower();
        
            zring(n=num_plantes)
            move(x=orbit_radius,z=planet_carrier_bottom_plate_height)
                planetGear();
        }
        move(z=.25)
            planetCarrierUpper();
        */
        move(z=0) annulus();

        color("silver")
        move(z=planet_carrier_height-1)
        zflip()
            screw(screwsize=5,
            headsize=get_metric_bolt_head_size(5), screwlen=25);

        
        move(z=annulus_size[z])
            cover();        
        
        move(z=cover_size[z]+annulus_size[z]+fit_clearance) {
            
            move(z=2+1.5)
            move(z=HPulleyH) zflip()
            color("silver") hobbedPulley();
            
            move(z=2.4)
            move(x=HPulleyD/2+get_bearing_outer_diam(608)/2)
                bearing(608);
            
            /*#move(x=HPulleyD/2,y=motorSize/2,z=5.5)
            xrot(-90)
            color("silver")
                myPC401();*/
            
            move(x=motorScrewSpacing/2,y=-motorScrewSpacing/2)
            difference() {
                zrot(-8)idler(h=11);
                /*move(z=11/2-(3+fit_clearance*2)/2)
                    cylinder(r=7,h=3+fit_clearance*2);*/
            }
            
            
            extruderCover();
        }
        
        //move(z=-43+cover_size[z]+annulus_size[z])
        //    import("./help/Bowden_Extruder_SBS-175.stl");
    }    
}

module extruderCover() {
    FilamentX = (HPulleyD-HPulleyHD/2)/2 + 0.2;
    FilamentZ = 5.5;
    h = FilamentZ+5.5;
    bearD = get_bearing_outer_diam(IDLER_BEAR);
    bearH = get_bearing_height(IDLER_BEAR);    
    gap=0.5;   
    
    difference() {
        union() {
            hull() {
                rrect([15,motorSize/2,h]);
                move(x=-motorSize/2+5,y=motorSize/2-5)
                    cylinder(r=5,h=h);
                move(x=motorSize/2-5,y=-motorSize/2+5)
                    cylinder(r=5,h=h);
                move(x=-motorSize/2+5,y=-motorSize/2+5)
                    cylinder(r=5,h=h);
            }
            //outerBody(h=h);
        }
        
        // Aussparrung PTFE Tube
        move(x=FilamentX,z=FilamentZ)
        xrot(90)
            cylinder(d=4,h=100,center=true);
        
        //Aussparrung PTFE Tube Holder PC4-01 
        move(x=FilamentX,z=FilamentZ,y=motorSize/2-4.5)
        xrot(-90)
            cylinder(d=5.7,h=4.5+1);
        
        // Aussparrung idler
        move(x=10,y=-motorSize/2-10,z=-1) {
            cube([30,40,h+2]);
        }
        
        //Smooth HobbedPulley to Bearing
        move(z=-1) {
            intersection() {
                hull() {
                    cylinder(d=HPulleyD+2,h=h+2);//Cut HobbedPulley
                    move(x=bearD/2,y=bearD/8)
                        cylinder(d=bearD+gap*2,h=h+2);
                }
                move(y=-50)
                    cube([100,100,100],center=true);
            }
        }
        
        move(z=-1) {                      
            cylinder(d=HPulleyD+2,h=h+2);//Cut HobbedPulley
        }        
        move(x=FilamentX+bearD/2, z=-1) {
            hull() {
                cylinder(d=bearD+gap*2,h=h+2);
                move(x=bearD/2)
                    cylinder(d=bearD+gap*2,h=h+2);
            }
        }
        
        move(x=14-3.5, z=FilamentZ,y=motorScrewSpacing/2)
        yrot(90)
            spannfederCut();

        //Nuts
        yflip_copy()
        move(x=-motorScrewSpacing/2,y=-motorScrewSpacing/2, z=11-4)
            screw(screwlen=h,headlen=5,tolerance=fit_clearance*2);
        
    }
}

module spannfederCut() {
    hull() {
        cylinder(30,d=3.25+clear);
        move(y=8.5)
            cylinder(30,d=3.25+clear);
    }
    hull() {
        cylinder(3.5,d=6.5);
        move(y=8.5)
            cylinder(1.5,d=6.5);
    }
}


IDLER_BEAR=608;
IdlerSpacing=10;
ZBUFF=0.1;
clear=0.3;
module idler(h=12,diai=8) {
    //Bearing
    BEARING_D = get_bearing_outer_diam(IDLER_BEAR);
    BEARING_H = get_bearing_height(IDLER_BEAR);
    
    difference() {
        union() {//Grundform
            hull() {
                cylinder(d=diai+1,h=h);
                move(x=7,y=50)
                    cylinder(d=diai/2,h=h);
                move(x=7,y=2)
                    cylinder(d=diai/2,h=h);
            }
            hull(){
                translate([2,0,0])cylinder(d=diai/2,h=h);
                translate([7,2,0])cylinder(d=diai/2,h=h);
                translate([2,36.25,0])cylinder(d=diai/2,h=h);
                translate([7,50,0])cylinder(d=diai/2,h=h);
            }
            // Erweiterung / Verstärkung im Lagerbereich
            move(x=-0.5,y=motorScrewSpacing/2)
                cylinder(d=BEARING_D-4,h=h);
        }

        // Bohrung für die Achse des Hebels
        move(z=-1) {
            /*move(z=-IdlerSpacing+2+1+(+20-5))
            zflip()
                mainScrew(screwlen=20,head=5);*/
            move(z=h/2+2)
                screw(screwlen=h,headlen=25,tolerance=fit_clearance*2);
        }

        // Aussparrung für Kugellagers
        move(x=-0.5, y=motorScrewSpacing/2,z=(h-(BEARING_H+1))/2) {
            cylinder(d=BEARING_D+2,h=BEARING_H+1);
            down(BEARING_H/2+ZBUFF)
                cylinder(d=8+clear,h=h+10);
            down(BEARING_H/2+ZBUFF+0.5)
                cylinder(d=14,h=2);
        }

        // Einarbeitung einer "Griffmulde"
        move(x=0,y=43,z=3)
            rrect([5,10,h-6],r=diai/4);

        // Ausschnitt für die Federschraube mit Feder und U-Scheiben
        move(y=motorScrewSpacing, z=h/2)
        yrot(90) {
            hull() {
                cylinder(d=4+clear,h=30);
                move(y=6.5)
                    cylinder(d=4+clear,h=30);
            }
            move(z=7.5)
            hull() {
                cylinder(d=10,h=30);
                move(y=6.5)
                    cylinder(d=10,h=30);
            }
        }
    }
    // Verstärkung im Bereich des Kugellagers (Dient gleichzeitig der Zetrierung des Lagers)
    difference(){
        // Grundform (2x Kegelstumpf)
        union(){
            translate([-0.5,motorScrewSpacing/2,(h-BEARING_H-1)/2])cylinder(0.35,d1=8+10,d2=8+5);
            translate([-0.5,motorScrewSpacing/2,(h-BEARING_H-1)/2+BEARING_H+1-0.35])cylinder(0.35,d1=8+5,d2=8+10);
            }
        // Ausschnitt für die Lagerwelle
        translate([-0.5,motorScrewSpacing/2,-ZBUFF])cylinder(h+1*2,d=8+clear);
        }
}

module myPC401() {
    difference() {
        union() {
            cylinder(d=5.7,h=4);
            move(z=4)
                cylinder(d=10,h=16,$fn=8);
        }
        cylinder(d=4,h=100,center=true);
    }
}

module hobbedPulley() {
    difference() {
        cylinder(d=HPulleyD,h=HPulleyH);
        move(z=HPulleyHT)
            rotate_extrude(convexity=10)
            move(x=HPulleyD/2)
                circle(d=HPulleyHD);
    }
}


module motorSuspensionCut(h=8, yspace=0, xspace=0) {
    cylinder(d=motorScrewSpacing, h=h+2);

    //zring(n=4)
    yflip_copy()
    xflip_copy()
    move(x=motorScrewSpacing/2, y=motorScrewSpacing/2) {
        hull() {
            xflip_copy()
            yflip_copy()
            move(x=-xspace/2, y=-yspace/2)
                cylinder(d=3,h=h+2);
        }
    }
}

module motorSuspension(r=2.5,h=WALL, yspace=0, xspace=0) {
    difference() {
        cube([motorSize,motorSize,h]);
        move(x=motorSize/2, y=motorSize/2, z=-1)
            motorSuspensionCut(h+2,yspace=yspace, xspace=xspace);
    }
}

module basePlate(h=base_size[z]) {
    difference() {
        union() {
            outerBody(h=h);
            
            //Combine plates
            move(x=-motorSize/2-5,y=-motorSize/2,z=h-4)
                cube([10,motorSize,4]);
            //Profile plate
            move(z=4/2,x=-motorSize/2-20/2,z=h-4/2)
                rrect([20,motorSize,4],center=true,r=5);            
        }
        
        //Sungear
        cylinder(r=max(sun_gear_hub_radius, gearOuterRadius(sun_teeth)) +moving_clearance*2, h=1000, center=true);
        
        move(z=-1)
            motorSuspensionCut(h=h-base_wall);

        //Screws
        motorScrewPos(screwHole=true);
        
        
        //module screwHole(size=3, length=10, headLen=4, clearance=0, support=false) {
        
        move(x=-motorSize/2-10, z=-10+h-0.75)
        yspread(motorSize/3,n=3) 
            screwHole(length=10,headLen=4, clearance=fit_clearance);
        
    }
}


module cover() {
    bearH = get_bearing_height(bearing);
    bearD = get_bearing_outer_diam(bearing);

    difference() {
        outerBody(h=cover_size[z]);
        
        //Motor screws 
        //motorScrewPos(screwHole=true);
        move(x=motorScrewSpacing/2,y=-motorScrewSpacing/2)
            cylinder(d=m3_diameter,h=100,center=true);
        move(x=-motorScrewSpacing/2,y=-motorScrewSpacing/2)
            cylinder(d=m3_diameter,h=100,center=true);
        move(x=-motorScrewSpacing/2,y=motorScrewSpacing/2)
            cylinder(d=m3_diameter,h=100,center=true);
        
        move(x=motorScrewSpacing/2,y=motorScrewSpacing/2,z=-2.5)
            screwHole(length=cover_size[z],headLen=4, clearance=fit_clearance);
        
        // Planet carrier
        move(z=-1)
            cylinder(h=cover_size[z]+1-cover_wall-bearH, r=planet_carrier_radius+1);
        
        // Bearing pocket
        move(z=cover_size[z]-bearH-cover_wall-1)
            cylinder(h=bearH+fit_clearance+1, d=bearD+fit_clearance);

        // Output bolt shaft.
        move(z=-1)
            cylinder(h=cover_size[z]+2, r=m5_diameter/2+moving_clearance);
    }
}


module planetCarrierUpper() {
    difference() {
        move(z=planet_carrier_height/2)
            cylinder(h=planet_carrier_height/2, r=planet_carrier_radius);
        planetCarrierVoid();
    }
}

module planetCarrierLower() {
    difference() {
        cylinder(h=planet_carrier_height/2, r=planet_carrier_radius);
        planetCarrierVoid();
    }
}

module planetCarrierVoid() {
    planet_radius = gearOuterRadius(planet_teeth);
    
    // Sun gear
    move(z=-.1)
    cylinder(r=max(sun_gear_hub_radius, gearOuterRadius(sun_teeth)) +moving_clearance*2, h=planet_carrier_bottom_plate_height+planet_gear_thread_height+moving_clearance+.1);    
    
    //Planet gears
    zring(n=num_plantes)
    move(x=orbit_radius,z=planet_carrier_bottom_plate_height)
    difference() {
        cylinder(r=planet_radius+1, h=planet_gear_thread_height+moving_clearance);
        cylinder(d=5-fit_clearance*2,h=1000,center=true);
    }

    // Drive bolt
    //Nut
    translate([0, 0, planet_carrier_height-1])
        rotate([180, 0, 30])
        cylinder(h=m5_bolt_head_height+.1, r=m5_nut_diameter/2, $fn=6);
    //Bolt
    translate([0, 0, planet_carrier_height-layer_height*2+1])
        rotate([180, 0, 0])
        cylinder(h=m5_bolt_head_height+1, r=m5_diameter/2);
    
    // Planet carrier nuts & bolts.
    zrot(360/num_plantes/2)
    zring(n=3) 
    move(x=orbit_radius) {        
        move(z=planet_carrier_height/2) //headLen
            zflip() 
            screwHole(headLen=3,length=planet_carrier_height/2-3+.25,clearance=fit_clearance);
        
        move(z=planet_carrier_height/2)
            nutHole(length=planet_carrier_height/2-3,headLen=3);
    }
}



module planetGear() {
    difference() {
        gear(teeth=planet_teeth,h=planet_gear_thread_height);
        cylinder(d=5+fit_clearance*2,h=1000,center=true);
    }    
}

module sunGear() {
    difference() {
        union() {
            cylinder(h=sun_gear_hub_height, r=sun_gear_hub_radius);
            move(z=sun_gear_hub_height)
                gear(sun_teeth, sun_gear_thread_height-.1);            
        }
        
        move(z=-1) //Motor shaft
            cylinder(h=sun_gear_hub_height+sun_gear_thread_height+2,
                r=5/2+0.125);
        
        //Madenschrauben
        move(z=sun_gear_hub_height/2)
            zrot_copy(90) xrot(90)
                cylinder(h=sun_gear_hub_radius*2+2, r=2.8/2,center=true);
    }
}


module outerBody(h) {
    /*diaOffset = 6;
    union() {        
        hull_around() {
            cylinder(d=gearOuterRadius(ring_teeth)*2+diaOffset,h=h);
            move(x=motorScrewSpacing/2,y=motorScrewSpacing/2)
                cylinder(d=3.2+diaOffset,h=h);
            move(x=motorScrewSpacing/2,y=-motorScrewSpacing/2)
                cylinder(d=3.2+diaOffset,h=h);
            move(x=-motorScrewSpacing/2,y=motorScrewSpacing/2)
                cylinder(d=3.2+diaOffset,h=h);
            move(x=-motorScrewSpacing/2,y=-motorScrewSpacing/2)
                cylinder(d=3.2+diaOffset,h=h);
        }
    }   */
    move(z=h/2)
        rrect([motorSize,motorSize,h],r=5,center=true);
}

module annulus() {
    difference() {
        //Basebody
        outerBody(h=annulus_size[z]);
       
        move(z=-1) {
            
            linear_extrude(height=annulus_size[z]+2) {
                //Gear
                gear2D(ring_teeth, gear_modulus, gear_pressure_angle, gear_depth_ratio, -gear_clearance);
            }
            
            //Screwholes
            motorScrewPos(screwHole=true);
        }
    }
}


module motorScrewPos(screwHole=false) {
    xflip_copy() yflip_copy()
    move(x=motorScrewSpacing/2,y=motorScrewSpacing/2) {
        if(screwHole)
            cylinder(d=m3_diameter,h=10000,center=true);
        else
            children();
    }
}