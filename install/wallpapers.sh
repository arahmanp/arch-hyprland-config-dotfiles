#!/usr/bin/env bash
# Generate a small set of tasteful Catppuccin wallpapers (only if none exist).

generate_wallpapers() {
    log_step "Preparing wallpapers"
    local dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$dir"

    # Don't clobber a user's existing wallpapers.
    if find "$dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        2>/dev/null | grep -q .; then
        log_info "Wallpapers already exist in $dir (skipping generation)."
        return
    fi

    local IM=""
    if   has_cmd magick;  then IM="magick"
    elif has_cmd convert; then IM="convert"
    else log_warn "ImageMagick missing; skipping wallpaper generation."; return
    fi

    local W=2560 H=1440
    gen() { "$IM" -size "${W}x${H}" "$@" 2>/dev/null || true; }

    gen -define gradient:angle=135 gradient:'#cba6f7'-'#1e1e2e'  "$dir/01-mocha-mauve.png"
    gen -define gradient:angle=135 gradient:'#89b4fa'-'#181825'  "$dir/02-mocha-blue.png"
    gen -define gradient:angle=135 gradient:'#f5c2e7'-'#1e1e2e'  "$dir/03-mocha-pink.png"
    gen -define gradient:angle=135 gradient:'#94e2d5'-'#181825'  "$dir/04-mocha-teal.png"
    gen radial-gradient:'#313244'-'#11111b'                      "$dir/05-mocha-radial.png"
    gen plasma:'#1e1e2e'-'#45475a'                               "$dir/06-mocha-plasma.png"

    if find "$dir" -maxdepth 1 -type f -iname '*.png' 2>/dev/null | grep -q .; then
        log_success "Generated starter wallpapers in $dir"
    else
        log_warn "Wallpaper generation produced no files (continuing)."
    fi
}
