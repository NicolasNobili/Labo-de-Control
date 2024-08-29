$fn=256;

l=150;
w=15;
h=10;

dtorn=3.5;

back=25;

module gancho(){
    linear_extrude(height=5)polygon(points=5*[[0,0],[1.5,0],[2,0.5],[2,1],[1.5,1.5],[1.5,1],[1,1],[0,2]]);
}

module barra(){
    difference(){
        //barra
        translate([-back,-w/2,0])cube([l+back,w,h]);
        //centro servo
        translate([0,0,h-2.7+0.001])cylinder(d=14,h=2.7);
        //alas servo
        translate([0,0,h-2.7+0.001])linear_extrude(height=2.7)polygon(points=[[0,-4.5],[6,-4.5],[18.5,-2],[18.5,2],[6,4.5],[0,4.5]]);
        translate([0,0,h-2.7+0.001])rotate([0,0,180])linear_extrude(height=2.7)polygon(points=[[0,-4.5],[6,-4.5],[18.5,-2],[18.5,2],[6,4.5],[0,4.5]]);
        translate([0,0,h-2.7+0.001])rotate([0,0,90])linear_extrude(height=2.7)polygon(points=[[0,-4.5],[6,-4.5],[18.5,-2],[18.5,2],[6,4.5],[0,4.5]]);
        translate([0,0,h-2.7+0.001])rotate([0,0,-90])linear_extrude(height=2.7)polygon(points=[[0,-4.5],[6,-4.5],[18.5,-2],[18.5,2],[6,4.5],[0,4.5]]);
        //tornillo
        translate([0,0,-0.001])cylinder(d=dtorn,h=h+0.2);
        for ( i = [0:1:4]) 
            translate([l-6.5/2-i*10,-12.5,h/2])rotate([-90,0,0])cylinder(d=dtorn,h=25);
        
        translate([10,0,-5])cylinder(d=1.5,h=h+10+0.2);
        translate([-10,0,-5])cylinder(d=1.5,h=h+10+0.2);
        
    }
    translate([40,-15/2,10])rotate([90,180,90])gancho();
    
}

d_int=6;
d_ext=19;
h_rule=6+0.5+1.5;
module ruleman(){
    difference(){
        union(){
            cylinder(d=d_ext+3,h=h_rule);
            translate([0,-(d_ext+3)/2,0])cube([(d_ext+3)/2+h+5,d_ext+3,h_rule]);
        }
        translate([0,0,1.5+0.001])cylinder(d=d_ext+0.3,h=h_rule);
        translate([0,0,-0.001])cylinder(d=d_int+5,h=h_rule+0.002);
        translate([(d_ext+3)/2+5+0.001,-w/2-0.2/2,-0.001])cube([h,w+0.2,h_rule+0.002]);
        translate([(d_ext+3)/2+5+0.001+h/2,-12.5,h_rule/2])rotate([-90,0,0])cylinder(d=dtorn,h=25);
   } 
}

d_extt=22;
h_rulet=1.5;
module tapa_ruleman(){
    difference(){
        union(){
            cylinder(d=d_extt+3,h=h_rule+h_rulet);
            translate([0,-(d_extt+3)/2,0])cube([(d_extt+3)/2+h+5,d_extt+3,h_rule+h_rulet]);
        }
        translate([0,0,-0.001])cylinder(d=d_int+5,h=h_rule+h_rulet+0.002);
        translate([(d_ext+3)/2+5+0.001+h/2,-12.5-2,h_rule/2])rotate([-90,0,0])cylinder(d=dtorn,h=25+5);
        translate([0,0,-0.01])union(){
            cylinder(d=d_ext+3+0.5,h=h_rule);
            translate([0,-(d_ext+3)/2-0.25,0])cube([(d_ext+3)/2+h+5,d_ext+3+0.5,h_rule]);
        }
   } 
}

lp=200;
wp=8;
hp=8;
backp=10;
imul=21;
imuw=12;
module pendulo(){
    difference(){
        union(){
            translate([-backp,-wp/2,0])cube([lp+backp,wp,hp]);
            cylinder(d=wp,h=hp+4);
        }
        translate([0,0,-0.001])cylinder(d=dtorn,h=hp+4+0.002);
        translate([lp-backp,0,-0.001])cylinder(d=dtorn,h=hp+0.002);
    }
    translate([50,-imul/2,0])cube([2,imul,imuw+hp]);
}

lb=40.5;
wb=20.2;
hala=28.5;
espala=2.5;
esp=2.5;
dtornito=1.5;
disttor1=5;
disttor2=4;
htorn=6;
ladd=7;
module base(){
    difference(){
        cube([lb+2*ladd,wb+2*esp,hala+esp]);
        translate([ladd-0.5,esp-0.5,esp+0.001])cube([lb+1,wb+1,hala]);
        translate([esp-0.5+20,esp-0.5,esp+0.001+3])cube([lb+1,wb+1,hala-5]);
        translate([6+1-disttor2,wb/2+esp+disttor1,hala+esp-htorn+0.001])cylinder(d=dtornito,h=htorn);
        translate([6+1-disttor2,wb/2+esp-disttor1,hala+esp-htorn+0.001])cylinder(d=dtornito,h=htorn);
        translate([lb+ladd+disttor2,wb/2+esp+disttor1,hala+esp-htorn+0.001])cylinder(d=dtornito,h=htorn);
        translate([lb+ladd+disttor2,wb/2+esp-disttor1,hala+esp-htorn+0.001])cylinder(d=dtornito,h=htorn);
        translate([3.5,-1,5])rotate([-90,0,0])cylinder(d=dtorn,h=30);
        translate([3.5,-1,22])rotate([-90,0,0])cylinder(d=dtorn,h=30);
    }
    translate([ladd,-5,0])cube([lb+2*ladd+20-ladd,wb+2*esp+10,esp]);
    translate([lb+2*ladd,0,0])cube([20,120,esp]);
    translate([lb+2*ladd+7.5,0,0])cube([5,120,3*esp]);
    translate([lb+2*ladd+12.5,120-10,7.5])rotate([90,-90,-90])gancho();
}

htop=54.5;
hpote=80;
module pote(){
    difference(){
        cube([ladd-0.5+esp,wb+2*esp+2*esp,hpote+esp]);
        translate([esp,esp-0.1,-0.001])cube([ladd-0.5+esp,wb+2*esp+0.2,hpote+esp+0.002]);
        translate([3.5+esp,-10,5])rotate([-90,0,0])cylinder(d=dtorn,h=50);
        translate([3.5+esp,-10,22])rotate([-90,0,0])cylinder(d=dtorn,h=50);
    }
    difference(){
        translate([0,0,hpote+esp])cube([41+ladd+esp,wb+2*esp+2*esp,esp]);
        translate([ladd+esp+30,wb/2+2*esp,hpote+esp-0.001])cylinder(d=7.5,h=esp+0.002);
        translate([ladd+esp+30,wb/2+2*esp-4.5-7.5/2,hpote+esp*1.5-0.001])cube([3.5,2,esp+0.05],center=true);
    }
    translate([0,0,hpote+esp])rotate([-90,0,0])linear_extrude(height=esp-0.1)polygon(points=[[0,0],[25,0],[0,25]]);
    translate([0,wb+2*esp+esp+0.1,hpote+esp])rotate([-90,0,0])linear_extrude(height=esp-0.1)polygon(points=[[0,0],[25,0],[0,25]]);
}

lperi=30;
espperi=2;
module pote_perno(){
    difference(){
        union(){
            translate([lperi/2,w/2,0])cylinder(d=10,h=15);
            cube([lperi,w,espperi]);
        }
        translate([lperi/2,w/2,-0.001])cylinder(d=5.9,h=15+0.002);
        translate([lperi/2-10,w/2,-0.001])cylinder(d=2.2,h=espperi+0.002);
        translate([lperi/2+10,w/2,-0.001])cylinder(d=2.2,h=espperi+0.002);
    }
}



//translate([0,0,h])rotate([180,0,0])barra();
//translate([l-6.5,0,26])rotate([0,90,0])ruleman();
//translate([l-6.5,0,26])rotate([0,90,0])tapa_ruleman();
//translate([l+11,0,26])rotate([0,-90,0])pendulo();
//translate([-37,-esp-wb/2,-40])base();
//translate([-esp-37,-2*esp-wb/2,-40])pote();
//translate([-lperi/2,-w/2,h])pote_perno();

//barra();
//ruleman();
//translate([0,0,9.5])rotate([180,0,0])tapa_ruleman();
//pendulo();
//base();
//rotate([0,-90,0])pote();
//pote_perno();

