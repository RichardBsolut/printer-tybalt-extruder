use <../libs/bcad.scad>
use <../libs/screw.scad>
use <../libs/bearing.scad>
include <./extruder.scad>


module extr_assembly_01(explode=true) {
    // view: [ -4.32, 6.88, 8.19 ] [ 45.50, 0.00, 24.50 ] 260
    // title: Step 1
    // desc: 
    planetCarrierLower();
    
    zring(3)
    move(x=orbit_radius,z=explode?20:planet_carrier_bottom_plate_height) {
        if(explode)
            yrot(-90) arrow();        
        move(z=explode?20:0)
            planetGear();
    }
}



module extr_assembly_02(explode=true) {
    // view: [ -0.53, 5.89, -11.51 ] [ 126.70, 0.00, 42.70 ] 260
    // title: Step 2
    // desc: 
    planetCarrierUpper();
    
    if(explode)
        yrot(90) arrow();
    
    color("silver")
    move(z=planet_carrier_height-2-(explode?45:0))
    zflip()zrot(30)
    screw(screwsize=5,screwlen=25,headfn=6);    
}

module extr_assembly_03(explode=true) {
    // view: [ -0.53, 5.89, -11.51 ] [ 116.20, 0.00, 46.90 ] 362
    // title: Step 3
    // desc: 
    if(explode)
        move(z=-6) yrot(90) arrow();
    move(z=-(explode?30:0)) {
        extr_assembly_01(false);
        
        zring(3) {
            move(z=2-(explode?30:0)) {                
                zrot(60) move(x=orbit_radius) {
                    if(explode) move(z=20) yrot(90) arrow();
                    zflip()
                        color("silver") 
                        screw(screwsize=3,screwlen=10,headlen=2,headfn=6);    
                }
            }
        }
    }
    
    extr_assembly_02(false);
        zring(3) {
            move(z=2+(explode?10:0)) {                
                zrot(60) move(x=orbit_radius) {
                    if(explode) move(z=20) yrot(-90) arrow();
                    move(z=8+(explode?40:0))
                        color("silver") metric_nut();
                }
            }
        }
}



module extr_assembly_04(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 77.70, 0.00, 26.60 ] 495
    // title: Step 4
    // desc: 
    17HD(center=true);
    if(explode) move(z=20) yrot(-90) arrow();
    move(z=1.5+(explode?30:0))
        sunGear();
}

module extr_assembly_05(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 77.70, 0.00, 23.10 ] 495
    // title: Step 5
    // desc: 
    extr_assembly_04(false);
    basePlate();
        
    if(explode) move(z=25) yrot(-90) arrow();
    move(z=base_size[z]+(explode?30:0))
        annulus();
}



module extr_assembly_06(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 70.70, 0.00, 21.00 ] 495
    // title: Step 6
    // desc: 
    
    extr_assembly_05(false);
    if(explode) move(z=28) yrot(-90) arrow();
    move(z=base_size[z]+(explode?35:0))
        extr_assembly_03(false);    
}

module extr_assembly_07(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 128.80, 0.00, 23.80 ] 495
    // title: Step 7
    // desc: 
    
    cover();
    if(explode) move(z=-5) yrot(90) arrow();
    move(z=cover_size[z]-cover_wall-get_bearing_height(bearing)-(explode?30:0))
        bearing(bearing,outline=true);
}

module extr_assembly_08(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 67.90, 0.00, 14.00 ] 495
    // title: Step 8
    // desc: 
    
    extr_assembly_06(false);
    if(explode) move(z=50) yrot(-90) arrow();
    move(z=base_size[z]+annulus_size[z]+(explode?50:0))
        extr_assembly_07(false);
}


module extr_assembly_09(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 66.90, 0.00, 24.80 ] 495
    // title: Step 9
    // desc: 
    h = base_size[z]+annulus_size[z]+cover_size[z];
    extr_assembly_08(false);
    
    move(x=motorScrewSpacing/2,y=motorScrewSpacing/2,z=h-2) {
        if(explode) move(z=15) yrot(-90) arrow();
        move(z=explode?60:0)
        color("silver") 
            screw(screwsize=3,screwlen=30,headlen=2);
    }
}

module extr_assembly_10(explode=true) {
    // view: [ -3.02, 12.40, 6.10 ] [ 66.90, 0.00, 24.80 ] 495
    // title: Step 10
    // desc: 
    h = base_size[z]+annulus_size[z]+cover_size[z];
    extr_assembly_09(false);
    
    move(z=h+HPulleyH+2) {
        if(explode) move(z=10) yrot(-90) arrow();
        move(z=explode?35:0)
        color("silver") 
            zflip() hobbedPulley();
    }
}


module extr_assembly_11(explode=true) {
    // view: [ 0.00, 0.00, 0.00 ] [ 73.90, 0.00, 68.40 ] 680
    // title: Step 11
    // desc: 
    h = base_size[z]+annulus_size[z]+cover_size[z];
    extr_assembly_10(false);
    
    move(z=h+(explode?25:0)) {
        if(explode) move(z=0) yrot(-90) arrow();       
        extruderCover();
        move(z=11-2+(explode?60:0)) { 
            yflip_copy()
            move(x=-motorScrewSpacing/2,y=-motorScrewSpacing/2) {
                if(explode) move(z=-50) yrot(-90) arrow();
                color("silver") screw(screwsize=3,screwlen=40,headlen=2);
            }
        }
    }
    
}

module extr_assembly_12(explode=true) {
    // view: [ 0.00, 0.00, 0.00 ] [ 56.40, 0.00, 43.20 ] 360
    // title: Step 12
    // desc: 
    h=11;
    BEARING_H = get_bearing_height(IDLER_BEAR);
    yrot(explode?90:0) {
        idler();        
        move(x=-0.5-(explode?50:0), y=motorScrewSpacing/2,z=(h-(BEARING_H))/2+0.5) {
            if(explode) move(x=25,z=BEARING_H/2) zrot(180) arrow();       
            bearing(608,outline=true);
        }
    }
}

module extr_assembly_13(explode=true) {
    // view: [ 0.00, 0.00, 0.00 ] [ 52.90, 0.00, 20.10 ] 360
    // title: Step 13
    // desc: 
    
    extr_assembly_12(false);
    h=11;
    BEARING_H = get_bearing_height(IDLER_BEAR);
    move(x=-0.5, y=motorScrewSpacing/2,z=(h-(BEARING_H+1))/2+(explode?30:0)) { 
        if(explode) move(z=-8) yrot(-90) arrow();   
        move(z=11+2.5)
            zflip() plug();
    }
}

module extr_assembly_14(explode=true) {
    // view: [ 0.00, 0.00, 0.00 ] [ 60.60, 0.00, 62.80 ] 680
    // title: Step 14
    // desc: 
    h = base_size[z]+annulus_size[z]+cover_size[z];
    extr_assembly_11(false);
    move(x=motorScrewSpacing/2,y=-motorScrewSpacing/2, z=h+(explode?40:0)) {
        extr_assembly_13(false);    
        move(z=11+(explode?60:0)) {
            if(explode) move(z=-48) yrot(-90) arrow();   
            if(explode) move(z=-90) yrot(-90) arrow();   
            color("silver") screw(screwsize=3,screwlen=40,headlen=2);
        }
    }    
}
