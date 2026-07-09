-- welcome_board/pagination.lua
-- Splits long text into fixed-length pages, breaking at line boundaries so a
-- page never exceeds the character limit and words are never cut mid-line.
--
-- This keeps every rendered textarea small, which prevents Luanti from lagging
-- or straining when displaying large amounts of content.

local P = {}

-- Split `text` into a list of page strings, each <= max_chars where possible.
-- Breaks are made at newline boundaries. A single line longer than max_chars
-- is placed on its own page rather than being cut (rare, and better than a
-- broken word), so the limit is a strong guideline with graceful degradation.
function P.paginate(text, max_chars)
    max_chars = max_chars or 1000
    if not text or text == "" then
        return { "" }
    end

    -- If the whole thing fits on one page, short-circuit.
    if #text <= max_chars then
        return { text }
    end

    local pages = {}
    local current = {}
    local current_len = 0

    -- Split into lines, preserving the structure. We re-add newlines as we go.
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local line_len = #line + 1  -- +1 for the newline we'll add back

        if current_len + line_len > max_chars and current_len > 0 then
            -- Flush current page and start a new one
            table.insert(pages, table.concat(current, "\n"))
            current = {}
            current_len = 0
        end

        table.insert(current, line)
        current_len = current_len + line_len
    end

    -- Flush the final page
    if #current > 0 then
        table.insert(pages, table.concat(current, "\n"))
    end

    if #pages == 0 then
        pages = { "" }
    end

    return pages
end

-- Count how many pages `text` would require at the given limit.
function P.count_pages(text, max_chars)
    return #P.paginate(text, max_chars)
end

-- Clamp a page index into the valid 1..N range.
function P.clamp_page(page, num_pages)
    if page < 1 then return 1 end
    if page > num_pages then return num_pages end
    return page
end

return P
