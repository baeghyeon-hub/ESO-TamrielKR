-- ============================================================
-- TamrielKR IME: Korean Syllable Composer (State Machine)
-- ============================================================

local KM = TamrielKR_IME_KeyMap

-- ============================================================
-- UTF-8 encoder
-- ============================================================

local function Utf8Encode(codepoint)
  if codepoint <= 0x7F then
    return string.char(codepoint)
  elseif codepoint <= 0x7FF then
    return string.char(
      0xC0 + math.floor(codepoint / 0x40),
      0x80 + (codepoint % 0x40)
    )
  elseif codepoint <= 0xFFFF then
    return string.char(
      0xE0 + math.floor(codepoint / 0x1000),
      0x80 + (math.floor(codepoint / 0x40) % 0x40),
      0x80 + (codepoint % 0x40)
    )
  else
    return string.char(
      0xF0 + math.floor(codepoint / 0x40000),
      0x80 + (math.floor(codepoint / 0x1000) % 0x40),
      0x80 + (math.floor(codepoint / 0x40) % 0x40),
      0x80 + (codepoint % 0x40)
    )
  end
end

-- ============================================================
-- Syllable computation: (cho * 21 + jung) * 28 + jong + 0xAC00
-- ============================================================

local function ComposeSyllable(cho, jung, jong)
  local choIdx = KM.JAMO_TO_CHO[cho]
  local jungIdx = KM.JAMO_TO_JUNG[jung]
  local jongIdx = 0
  if jong then
    jongIdx = KM.JAMO_TO_JONG[jong] or 0
  end
  if not choIdx or not jungIdx then
    return nil
  end
  return (choIdx * 21 + jungIdx) * 28 + jongIdx + 0xAC00
end

-- ============================================================
-- Composer object
-- ============================================================

TamrielKR_IME_Composer = {}
TamrielKR_IME_Composer.__index = TamrielKR_IME_Composer

function TamrielKR_IME_Composer:New()
  local obj = setmetatable({}, self)
  obj.state = "EMPTY"   -- EMPTY | CHO | CHO_JUNG | CHO_JUNG_JONG
  obj.cho = nil
  obj.jung = nil
  obj.jong = nil
  obj.committed = {}     -- list of committed UTF-8 strings
  return obj
end

-- Get the UTF-8 string of the currently composing character
function TamrielKR_IME_Composer:GetComposing()
  if self.state == "EMPTY" then
    return ""
  elseif self.state == "CHO" then
    return Utf8Encode(self.cho)
  elseif self.state == "CHO_JUNG" then
    local cp = ComposeSyllable(self.cho, self.jung, nil)
    if cp then
      return Utf8Encode(cp)
    end
    return Utf8Encode(self.cho) .. Utf8Encode(self.jung)
  elseif self.state == "CHO_JUNG_JONG" then
    local cp = ComposeSyllable(self.cho, self.jung, self.jong)
    if cp then
      return Utf8Encode(cp)
    end
    return Utf8Encode(self.cho)
  end
  return ""
end

-- Commit current composing character and clear state
function TamrielKR_IME_Composer:Commit()
  local composing = self:GetComposing()
  if composing ~= "" then
    self.committed[#self.committed + 1] = composing
  end
  self.state = "EMPTY"
  self.cho = nil
  self.jung = nil
  self.jong = nil
end

-- Flush and return all committed text + composing char
function TamrielKR_IME_Composer:Flush()
  local result = table.concat(self.committed)
  self.committed = {}
  return result
end

-- Reset: commit and flush
function TamrielKR_IME_Composer:Reset()
  self:Commit()
  return self:Flush()
end

-- Feed a jamo codepoint into the composer
-- Returns: committed text (string, may be empty)
function TamrielKR_IME_Composer:Feed(jamo)
  local isConsonant = KM.IS_CONSONANT[jamo]
  local isVowel = KM.IS_VOWEL[jamo]

  if not isConsonant and not isVowel then
    return self:Reset()
  end

  -- ========================================
  -- State: EMPTY
  -- ========================================
  if self.state == "EMPTY" then
    if isConsonant then
      self.cho = jamo
      self.state = "CHO"
      return self:Flush()
    else -- isVowel
      -- Standalone vowel, commit immediately
      self.committed[#self.committed + 1] = Utf8Encode(jamo)
      return self:Flush()
    end

  -- ========================================
  -- State: CHO (have initial consonant only)
  -- ========================================
  elseif self.state == "CHO" then
    if isVowel then
      -- Form syllable: cho + jung
      self.jung = jamo
      self.state = "CHO_JUNG"
      return self:Flush()
    else -- isConsonant
      -- Commit previous cho, start new cho
      self:Commit()
      self.cho = jamo
      self.state = "CHO"
      return self:Flush()
    end

  -- ========================================
  -- State: CHO_JUNG (have initial + vowel)
  -- ========================================
  elseif self.state == "CHO_JUNG" then
    if isVowel then
      -- Try composite vowel
      local composites = KM.COMPOSITE_VOWELS[self.jung]
      if composites and composites[jamo] then
        self.jung = composites[jamo]
        return self:Flush()
      end
      -- Can't combine: commit current syllable, output standalone vowel
      self:Commit()
      self.committed[#self.committed + 1] = Utf8Encode(jamo)
      self.state = "EMPTY"
      return self:Flush()
    else -- isConsonant
      -- Try to add as Jongsung
      if KM.JAMO_TO_JONG[jamo] then
        self.jong = jamo
        self.state = "CHO_JUNG_JONG"
        return self:Flush()
      end
      -- Can't be Jongsung (e.g., ㄸ,ㅃ,ㅉ): commit, start new cho
      self:Commit()
      self.cho = jamo
      self.state = "CHO"
      return self:Flush()
    end

  -- ========================================
  -- State: CHO_JUNG_JONG (full syllable)
  -- ========================================
  elseif self.state == "CHO_JUNG_JONG" then
    if isConsonant then
      -- Try composite Jongsung
      local composites = KM.COMPOSITE_JONG[self.jong]
      if composites and composites[jamo] then
        local compositeJong = composites[jamo]
        if KM.JAMO_TO_JONG[compositeJong] then
          self.jong = compositeJong
          return self:Flush()
        end
      end
      -- Can't combine: commit current syllable, start new cho
      self:Commit()
      self.cho = jamo
      self.state = "CHO"
      return self:Flush()
    else -- isVowel
      -- Vowel steals the Jongsung
      local decomposed = KM.DECOMPOSE_JONG[self.jong]
      if decomposed then
        -- Composite jong: split it
        -- First part stays as jong of current syllable
        -- Second part becomes cho of new syllable
        local firstJong = decomposed[1]
        local newCho = decomposed[2]
        self.jong = firstJong
        self:Commit()
        self.cho = newCho
        self.jung = jamo
        self.state = "CHO_JUNG"
        return self:Flush()
      else
        -- Simple jong: remove from current syllable, becomes new cho
        local newCho = self.jong
        self.jong = nil
        self.state = "CHO_JUNG"
        self:Commit()
        self.cho = newCho
        self.jung = jamo
        self.state = "CHO_JUNG"
        return self:Flush()
      end
    end
  end

  return self:Flush()
end

-- Backspace: undo last jamo input
-- Returns true if handled (composition changed), false if nothing to undo
function TamrielKR_IME_Composer:Backspace()
  if self.state == "CHO_JUNG_JONG" then
    -- Remove jong (or decompose composite jong)
    local decomposed = KM.DECOMPOSE_JONG[self.jong]
    if decomposed then
      self.jong = decomposed[1]
    else
      self.jong = nil
      self.state = "CHO_JUNG"
    end
    return true

  elseif self.state == "CHO_JUNG" then
    -- Remove jung (or decompose composite vowel)
    -- Check if jung is composite
    local found = false
    for baseVowel, combos in pairs(KM.COMPOSITE_VOWELS) do
      for _, compositeVowel in pairs(combos) do
        if compositeVowel == self.jung then
          self.jung = baseVowel
          found = true
          break
        end
      end
      if found then break end
    end
    if not found then
      self.jung = nil
      self.state = "CHO"
    end
    return true

  elseif self.state == "CHO" then
    self.cho = nil
    self.state = "EMPTY"
    return true
  end

  return false
end
