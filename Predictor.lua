-----------------------------------------------------------------------------
-- An implementation of the SSF2 AI which keeps distance.
-- 
-- 2017 Edward Hummerston
-----------------------------------------------------------------------------

require("SSF2-AI.Bot")

Predictor = {}
setmetatable(Predictor, {__index = Bot})
local Predictor_mt = {__index = Predictor}

-----------------------------------------------------------------------------
-- Override inherited constructor.
--
-- @param playerSlot     The controller port to represent that the algorithm
--                       will occupy.
-- @return               An instance of the created object.
-----------------------------------------------------------------------------
function Predictor.new(playerSlot)
   local self = Bot.new(playerSlot, 10)
   setmetatable(self, Predictor_mt)
   
   self.name = "Predictor"
   self.oppPrev = {x = 0, y = 0}
   self.oppCurr = {x = 0, y = 0}
   return self
end

-----------------------------------------------------------------------------
-- Calculates the difference between the opponent's positions in this frame
-- and the previous.
-----------------------------------------------------------------------------
function Predictor:estVel()
   return { x = self.oppCurr.x - self.oppPrev.x,
      y = self.oppCurr.y - self.oppPrev.y }
end

-----------------------------------------------------------------------------
-- Uses the estimated velocity of the opponent to predict what the distance
-- from the opponent will be by the time this frame's inputs are being
-- executed. Does not take into account this player's indented movement.
-----------------------------------------------------------------------------
function Predictor:estDis()
   local ret = {
      x = self:getDistance() + (self:estVel().x * self.inputDelay),
      y = self.oppCurr.y + (self:estVel().y * self.inputDelay) 
      }
   if ret.y < 0 then
      ret.y = 0
   end
   return ret
end

-----------------------------------------------------------------------------
-- Interprets the current game state and determines which action is
-- appropriate and thus what inputs the controller should be set to.
-----------------------------------------------------------------------------
function Predictor:advance()   
   self.oppPrev = self.oppCurr
   self.oppCurr = self:getOpponentAbsolutePosition()
   
   if self:estDis().x < 0x20 then   -- they are close
      self:setButton("Back",true)
      self.action = "walk back"
      self.i = -1
   elseif self:estDis().x > 0x30 then  -- we have a fireball out or the enemy is in the air
      self:setButton("Toward",true)
      self.action = "walk forward"
   else
      self.action = ""
   end
   
end