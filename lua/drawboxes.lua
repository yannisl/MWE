module(...,package.seeall)

local factor = 65782  -- big points vs. TeX points
local rule_width = 0.1

local function draw_pagebox(head,parent)
  while head do
    if head.id == 0 or head.id == 1 then -- hbox / vbox

      local wd = head.width                  / factor - rule_width
      local ht = (head.height + head.depth)  / factor - rule_width
      local dp = head.depth                  / factor - rule_width / 2

      draw_pagebox(head.list,head)
      local wbox = node.new("whatsit","pdf_literal")
      if head.id == 0 then -- hbox
        wbox.data = string.format("q 0.5 G %g w %g %g %g %g re s Q", rule_width, -rule_width / 2, -dp, wd, ht)
      else
        wbox.data = string.format("q 0.1 G %g w %g %g %g %g re s Q", rule_width, -rule_width / 2, 0, wd, -ht)
      end
      wbox.mode = 0

      head.list = node.insert_before(head.list,head.list,wbox)

    elseif head.id == 10 then -- glue
      local wd = head.spec.width
      local color = "0.5 G"
      if parent.glue_sign == 1 and parent.glue_order == head.spec.stretch_order then
        wd = wd + parent.glue_set * head.spec.stretch
        color = "0 0 1 RG"
      elseif parent.glue_sign == 2 and parent.glue_order == head.spec.shrink_order then
        wd = wd - parent.glue_set * head.spec.shrink
        color = "1 0 1 RG"
      end

      wbox = node.new("whatsit","pdf_literal")
      if parent.id == 0 then --hlist
        wbox.data = string.format("q %s [0.2] 0 d  0.5 w 0 0  m %g 0 l s Q",color,wd / factor)
      else -- vlist
        wbox.data = string.format("q 0.1 G 0.1 w -0.5 0 m 0.5 0 l -0.5 %g m 0.5 %g l s [0.2] 0 d  0.5 w 0.25 0  m 0.25 %g l s Q",-wd / factor,-wd / factor,-wd / factor)
      end
      wbox.mode = 0

      if head.prev then
        wbox.prev = head.prev
        head.prev.next = wbox
      end
      wbox.next = head
      head.prev = wbox
    else
    end
    head = head.next
  end
end

local function draw()
  draw_pagebox(tex.box["AtBeginShipoutBox"].list,tex.box["AtBeginShipoutBox"])
end

return { draw = draw }