--[[pod_format="raw",created="2026-04-17 09:53:00",modified="2026-04-17 20:34:39",revision=12]]
-- Podweb Browser v0.3 - entry point, state, and lifecycle
include("config.lua")
include("domains.lua")
include("renderer.lua")

window({ width=W, height=H, title="Podweb Browser v" .. VERSION})

local markdown_renderer_src = fetch("podnet://48932/podweb-markdown.lua")
if markdown_renderer_src then
	load(markdown_renderer_src)()
	print("successfully downloaded saturn91 latest parser")
else
	print("falling back to local parser")
	include("podweb-markdown.lua")
end

gui         = create_gui()
current_url = HOME_URL
document    = nil
url_bar     = nil
prev_mb     = 0
history     = {}
hist_idx    = 0

function push_history(url)
  while #history > hist_idx do
    table.remove(history)
  end
  add(history, url)
  while #history > 10 do
    table.remove(history, 1)
  end
  hist_idx = #history
end

function navigate_to(url)
  push_history(url)
  current_url = url
  load_page()
end

function go_back()
  if hist_idx > 1 then
    hist_idx   -= 1
    current_url = history[hist_idx]
    load_page()
  end
end

function go_forward()
  if hist_idx < #history then
    hist_idx   += 1
    current_url = history[hist_idx]
    load_page()
  end
end

local CONT_Y = BAR_H + 1
local CONT_H = H - BAR_H - 1

local ERROR_PAGE = [[
[p] ------------------------------------
[h1] Nothing is here.
[h2] Or how the world wide web would say
[img url=podnet://48932/404.gfx]
[p] Did you mistype? Then check the url.
[p] Did you come here via a link? Let the owner of the containing page know that their link is broken.
[p] ---------------------------------------
]]

function load_page()
  document = nil
  local src, err = fetch(current_url)
  if src and src ~= "" then
    document = pdw_parse(src, W, CONT_H)
    if #document.items == 0 then
      document = pdw_parse(ERROR_PAGE, W, CONT_H)
      if url_bar and url_bar.set_text then url_bar:set_text(current_url) end
      return
    end
    local meta = document.meta
    if meta.domain then
      local uid = string.match(current_url, "podnet://(%d+)/")
               or string.match(current_url, "^(https?://[^/]+)")
      register_domain_if_new(meta.domain, uid)
    end
    local uid            = string.match(current_url, "podnet://(%d+)/")
                        or string.match(current_url, "^(https?://[^/]+)")
    local display_domain = meta.domain
    if display_domain and known_domains[display_domain] ~= nil
       and known_domains[display_domain] ~= uid then
      display_domain = nil
    end
    if not display_domain then
      for domain, id in pairs(known_domains) do
        if id == uid then display_domain = domain; break end
      end
    end
    local path = string.match(current_url, "podnet://%d+/(.+)")
              or string.match(current_url, "^https?://[^/]+/(.+)")
              or ""
    local display = display_domain
      and (display_domain .. "/" .. path)
      or  current_url
    if url_bar and url_bar.set_text then url_bar:set_text(display) end
  else
    document = pdw_parse(ERROR_PAGE, W, CONT_H)
    if url_bar and url_bar.set_text then url_bar:set_text(current_url) end
  end
end

function _init()
  load_known_domains()

  url_bar = gui:attach_text_editor{
    x      = RELOAD_BTN.x + RELOAD_BTN.w + 4,
    y      = 2,
    width  = SUBMIT_BTN.x - (RELOAD_BTN.x + RELOAD_BTN.w + 4) - 4,
    height = BAR_H - 4,
    key_callback = {
      ["enter"] = function(self, k)
        local input = self:get_text()[1]
        if input and input ~= "" then
          navigate_to(resolve_url(input) or input)
        end
        return nil
      end
    }
  }
  if url_bar.set_text then url_bar:set_text(current_url) end
  push_history(current_url)
  load_page()
end

function _update()
  if document then
    pdw_update(document)
    if document.navigated_to then
      local nav = document.navigated_to
      if nav.url then
        navigate_to(nav.url)
      else
        local cur_user = string.match(current_url, "podnet://(%d+)/")
        navigate_to("podnet://" .. (nav.user or cur_user) .. "/" .. (nav.file or "index.podweb"))
      end
    end
  end

  local _, _, mb = mouse()
  if (prev_mb & 1) == 1 and (mb & 1) == 0 then
    if is_over_button(RELOAD_BTN) then load_page() end
    if is_over_button(BACK_BTN)    then go_back() end
    if is_over_button(FORWARD_BTN) then go_forward() end
    if is_over_button(SUBMIT_BTN) then
      local input = url_bar:get_text()[1]
      if input and input ~= "" then
        navigate_to(resolve_url(input) or input)
      end
    end
  end
  prev_mb = mb
  gui:update_all()
end

function _draw()
  cls(1)
  draw_address_bar()
  if document then pdw_doc(document, 0, CONT_Y) end
  gui:draw_all()
end