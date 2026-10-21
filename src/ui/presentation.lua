local P={}
local g=love.graphics
local shader
local code=[[
extern number clock;
extern number isolated;
number hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
number noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
number cloud(vec2 p){number n=0.0;number a=.5;for(int i=0;i<4;i++){n+=a*noise(p);p=p*2.03+7.0;a*=.5;}return n;}
vec4 effect(vec4 color,Image tex,vec2 uv,vec2 pixel){
 vec2 p=pixel/vec2(640.0,360.0);vec2 q=(p-vec2(.68,.44))*vec2(1.5,1.0);
 number r=length(q);number angle=atan(q.y,q.x)+clock*.025;
 number spiral=.5+.5*sin(angle*3.0-r*15.0+cloud(q*5.0)*3.0);
 number mist=cloud(p*5.0+vec2(clock*.012,-clock*.008));
 number band=exp(-abs(q.y+.20*sin(q.x*4.0+clock*.025))*5.0);
 vec3 c=vec3(.009,.018,.027)+mix(vec3(.022,.065,.13),vec3(.035,.17,.16),mist)*(band*.7+spiral*.28)*mist;
 c+=vec3(.105,.045,.13)*pow(spiral,4.0)*exp(-r*2.7)*mist;
 c+=vec3(.09,.15,.13)*exp(-r*r*95.0);
 c*=1.15+1.25*smoothstep(.08,.65,p.x);
 if(isolated>.5){
  vec2 disk=(p-vec2(.5,.5))*vec2(1.65,2.4);
  number radius=length(disk);
  number a=atan(disk.y,disk.x)-clock*.10;
  number arms=pow(.5+.5*sin(a*3.0-radius*19.0),3.0);
  number dust=cloud(disk*9.0+vec2(clock*.014,0.0));
  number edge=1.0-smoothstep(.36,.73,radius);
  number core=exp(-radius*radius*180.0);
  c=(mix(vec3(.025,.065,.11),vec3(.07,.27,.23),arms)*(.35+dust)*edge
     +vec3(.12,.055,.15)*pow(arms,3.0)*dust*edge*.55
     +vec3(.65,.67,.43)*core)*(1.0-smoothstep(.68,.78,radius));
 }
 return vec4(c,1.0)*color;
}
]]
function P.background(t,dim,isolated)
 if not shader then shader=g.newShader(code) end
 g.push('all');g.setColor(1,1,1);g.setShader(shader);shader:send('clock',t);shader:send('isolated',isolated and 1 or 0);g.rectangle('fill',0,0,640,360);g.setShader()
 for i=1,180 do
  local depth=1+i%3;local x=(i*137.37+t*depth*.35)%640;local y=(i*73.71+t*depth*.08)%360
  local light=(.3+.25*math.sin(t*(.4+i%5*.1)+i))*(x<340 and .45 or 1)
  if isolated then
   local dx,dy=(x/640-.5)*1.65,(y/360-.5)*2.4
   light=light*math.max(0,1-(dx*dx+dy*dy)/.36)^2
  end
  g.setColor(.74,.83,.79,light);g.rectangle('fill',math.floor(x),math.floor(y),1,1)
  if i%31==0 then g.setColor(.94,.91,.77,light*.5);g.rectangle('fill',x-2,y,5,1);g.rectangle('fill',x,y-2,1,5) end
 end
 if dim then g.setColor(.005,.008,.02,dim);g.rectangle('fill',0,0,640,360) end
 g.pop()
end
function P.machete(t)
 g.push('all');g.translate(470,179);g.rotate(.65)
 -- Broad, worn cutting blade; short wooden handle and brass rivets.
 for i=5,1,-1 do g.setColor(.35,.66,.72,.018);g.ellipse('fill',0,26,13+i*3,92+i*2) end
 g.setColor(.12,.19,.22);g.polygon('fill',-12,-40,15,-40,17,76,7,111,-9,121,-15,85)
 g.setColor(.43,.56,.56);g.polygon('fill',-11,-40,9,-40,10,79,3,108,-9,121,-12,84)
 g.setColor(.77,.85,.76);g.polygon('fill',-12,-40,-8,-40,-8,83,-5,105,-9,121,-15,85)
 g.setColor(.27,.38,.39);g.polygon('fill',9,-37,15,-40,17,76,7,111,3,108,10,79)
 g.setColor(.28,.36,.35);g.line(-5,6,2,13);g.line(-5,54,3,63);g.line(-3,83,1,87)
 g.setColor(.36,.27,.15);g.rectangle('fill',-17,-45,35,6)
 g.setColor(.65,.52,.28);g.rectangle('fill',-17,-45,35,2)
 g.setColor(.19,.105,.065);g.rectangle('fill',-7,-100,15,55)
 g.setColor(.42,.25,.12);g.rectangle('fill',-6,-99,6,52)
 for i=1,4 do g.setColor(.12,.08,.06);g.line(-5,-96+i*10,6,-93+i*10) end
 for _,y in ipairs({-87,-58}) do g.setColor(.76,.64,.36);g.circle('fill',0,y,2);g.setColor(.97,.85,.54);g.rectangle('fill',-1,y-1,1,1) end
 g.setColor(.52,.48,.34);g.rectangle('fill',-8,-103,17,4)
 local glint=(t*.09)%1
 g.setColor(.85,1,.93,math.sin(glint*math.pi)*.55);g.line(-10,-35+glint*130,-7,-27+glint*130)
 g.pop()
end
return P
