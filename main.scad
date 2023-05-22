//thales25 battery

//battery casing has 3 18650 batteries, a PCB.
//PCB has serial (1-wire?) communication with radio to inform of battery status and chemistry (enabling high power)
//has contacts on bottom to charge. I bet I can replace with USB-C.
//might regulate voltage provided to radio? idk.
//Twist-lock mechanism for battery is the hardest part mechanically but we can press/stamp those somehow, or worst-case can machine them manually or with CNC
//
//
$fn=100;

batt18650_l = 65;
batt18650_d = 18;
module cylarc(diameter, height, width){
//90 degrees assumed
	translate([0,0,-height/2]) intersection(){
		difference(){
			translate([0,0,height/2]) cylinder(d=diameter+width,h=height,center=true);
			translate([0,0,height/2]) cylinder(d=diameter,h=height*2,center=true);
		}
		translate([0,0,0]) cube([diameter+width,diameter+width,height],center=false);
	}
}
module batt18650(){
	l=batt18650_l; //mm
	d=batt18650_d;  //mm
	difference(){
		cylinder(h=l, d=d, center=true);
		translate([-4,-4.5,l/2-.9]) rotate([0,0,0]) linear_extrude(1) text( "+");
		translate([3.25,-2.25,-l/2-.1]) rotate([0,0,90]) linear_extrude(1) text("-");
	}
}

module thales25_battery_arrangement(spacing){
	bat_length = batt18650_l;
	union(){
		translate([0,18+spacing,0]) batt18650();
		translate([0,0,0]) rotate([0,180,0]) batt18650();
		translate([0,-18-spacing,0]) batt18650();
	}
}

batt_scaling = 1.05;
battery_box_width = 64;
battery_box_height = 80;
battery_lid_external_height = 6;
battery_lid_internal_height = 6;
battery_lid_internal_width = 60;
battery_lid_internal_depth = 23;
/*battery_box_depth = batt18650_d + 5;*/
battery_box_depth = 26;;
batt_box_lower_half = 2/3;
lowhalfheight = battery_box_height * batt_box_lower_half;
battbottspace = 3;
/*difference(){*/
	/*%translate([0,0,-lowhalfheight/2-batt18650_l/2+lowhalfheight-battbottspace]) cube([battery_box_depth, battery_box_width, lowhalfheight], center=true);*/
	/*scale([batt_scaling,batt_scaling,batt_scaling]) color("blue",.5) thales25_battery_arrangement(spacing=1);*/
	/*}*/

module battery_tabs(){
	width=10; //mm
	hole_d = 3; //probably 3, measured 2.9, but with tool not meant for it //mm
		//screw is countersunk
	countersink_d = 6;
	short_l = 14;//mm
	long_l = 16;//mm
	arc_cutout_circle_radius=26; //measured using h/2+w**2/(8h) method and some guesswork
	height=1.7;//1.8 sometimes
	flat_part_l = 10;//mm
	rise=3-height;//mm from one end (flat) to high end
	angle = asin(rise/width); //7.5ish degrees?
	sunken = 1; //1mm down from being flush, _NOT_ flush!
	echo(angle);
	module battery_tab(){
		//positioned based on center of screw hole!
		difference(){
			union(){
				difference(){
					cube([flat_part_l, width, height],center=true);
					union(){ //screw hole and countersink
						cylinder(d=hole_d,h=10, center=true);
						translate([0,0,height/2+.2]) rotate([0,180,0]) rotate_extrude(angle=360)
							polygon([[countersink_d/2,0],[hole_d/2,height],[0,height],[0,0]]);
					}
				}
				non_flat_part_l = long_l - flat_part_l;
				hull(){ //step down to match the angled bit
					color("red",.5) translate([-width/2,flat_part_l/2,-height/2]) rotate([0,0,0]) cube([width,.001,height]);
					color("blue",.5) translate([-width/2,7.5,-height*5/4]) rotate([0,-angle,0]) cube([width,.001,height]);
				}
				hull(){ //the angled bit that will get cut by the circle
					color("blue",.5) translate([-width/2,7.5,-height*5/4]) rotate([0,-angle,0]) cube([width,1,height]);
					color("green",.5) translate([-width/2,long_l,-height*5/4]) rotate([0,-angle,0]) cube([width,.01,height]);
				}
				//translate([-width/2,flat_part_l,-height*5/4]) rotate([0,-angle,0]) cube([width,non_flat_part_l,height]);
			}
			translate([width/(3.1415/2),long_l+arc_cutout_circle_radius-6,0]) cylinder(r=arc_cutout_circle_radius, h=10,center=true);
			translate([width/2-2.5,short_l-flat_part_l/2-1,0]) rotate([0,0,-10]) cylarc(diameter=5,height=10,width=5);
		}
	}
	translate([-6/2,-(55-11)/2,-height/2-sunken]) union(){
		battery_tab();
		translate([6,55-11,0]) rotate([0,0,180]) battery_tab();
	}
	//6 is accurate. not sure on 45
	//male piece is exactly 30mm long
	
	
}
module t25_battery_top(){
	//origin is center of twist lock mechanism, and height origin
	//is the flat part of the battery box top to ensure no gaps with
	//the radio when connected
	cutout_height = 5;//mm
	module connect_iso(){
		//the little electrical dots 
		isoh = 2;
		isod = 7;
		isoid = 6;
		isoih = 3;
		union(){
			difference(){
				translate([0,0,-cutout_height+isoh/2]) cylinder(d=isod,h=isoh,center=true);
				translate([0,0,-cutout_height+isoh/2+.001]) cylinder(d=isoid,h=isoih,center=true);
			}
		}

	}
	module cutout_basic(){
		cutout_length = 31;//mm
		cutout_width = 15; //first was 13.5
		//cylinder blocked out to ~14mm wide - maybe more
		//male width is 13mm, because of some placekeeping aluminum that part fits within
		intersection(){
			translate([0,0,-cutout_height/2]) cylinder(d=cutout_length, h=cutout_height,center=true);
			translate([0,0,-cutout_height/2]) cube([cutout_length, cutout_width, cutout_height*1.001],center=true);
		}
		
	}
	module tab_cutout(){
		w = 10;
		l = 18;
		h = cutout_height;
		cube([w,l,h],center=true);
	}
	module connector_holes(){
		d=3.5;
		offd = 6.5;
		h = 10;
		rot = 75;
		translate([0,0,-h/2]) union(){
			cylinder(d=d,h=h,center=true);
			rotate([0,0,rot]) translate([offd,0,0]) cylinder(d=d,h=h,center=true);
			rotate([0,0,-180+rot]) translate([offd,0,0]) cylinder(d=d,h=h,center=true);
			
		}
	}
	module forced_walls(thickness=.8){ //measured as 1 mm walls
	translate([0,0,-battery_lid_external_height/2]) difference(){
		cube([battery_box_depth,battery_box_width,battery_lid_external_height],center=true);
		cube([battery_box_depth-thickness,battery_box_width-thickness,battery_lid_external_height*2],center=true);
	}
	}
	union(){
		difference(){
			translate([0,0,-battery_lid_external_height/2]) cube([battery_box_depth,battery_box_width, battery_lid_external_height],center=true);
			translate([0,0,.001]){
				for(i= [0:15:30] ){
					rotate([0,0,90+i]) cutout_basic();
				}
			}
			//battery tab cutouts - should be same as battery tab in terms of positioning
			//
			//
			//holes for electrical connections
			connector_holes();


		}
		/*battery_tabs();*/
		connect_iso();
		forced_walls(thickness=.8);
	}
}
t25_battery_top();
/*battery_tabs();*/

//OEM battery box has a very slight curve to it, but I don't think I care enough right now.

