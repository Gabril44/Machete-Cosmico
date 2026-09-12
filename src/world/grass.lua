local W={}
function W.reset(self)
 self.weeds={}; self.grassGoal=18; for patch=0,2 do for i=0,11 do self.weeds[#self.weeds+1]={x=180+patch*98+(i%4)*15,y=250+math.floor(i/4)*17} end end
end
function W.update(self)
 local p=self.player
 for _,w in ipairs(self.weeds) do if not w.cut and p:isAttackActive() and p:inArc(w) then w.cut=true;self.cut=self.cut+1;self:burst(w.x,w.y,8,{.5,.65,.25}) end end

end
return W
