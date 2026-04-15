local Rejected, Accepted, Noop = 0, 1, 2

local keypad_symbol_map = {
  KP_Decimal = ".",
  KP_Delete = ".",
  KP_Multiply = "*",
  KP_Add = "+",
  KP_Subtract = "-",
  KP_Divide = "/",
  KP_Separator = ",",
  KP_Equal = "=",
}

local function keypad_text_from_key(key)
  local repr = key:repr()
  local digit = repr:match("^KP_([0-9])$")
  if digit then
    return digit
  end

  local symbol = keypad_symbol_map[repr]
  if symbol then
    return symbol
  end

  local keycode = key.keycode
  if keycode and keycode >= 0xffb0 and keycode <= 0xffb9 then
    return tostring(keycode - 0xffb0)
  end

  local keycode_symbol_map = {
    [0xffae] = ".",
    [0xffaa] = "*",
    [0xffab] = "+",
    [0xffad] = "-",
    [0xffaf] = "/",
    [0xffac] = ",",
    [0xffbd] = "=",
  }

  return keycode_symbol_map[keycode]
end

local function kp_digit_commit_processor(key, env)
  local context = env.engine.context
  if not context or not context:is_composing() then
    return Noop
  end

  local text = keypad_text_from_key(key)
  if not text then
    return Noop
  end

  local code = context.input
  if not code or code == "" then
    return Noop
  end

  context:clear()
  env.engine:commit_text(code .. text)
  return Accepted
end

return kp_digit_commit_processor
