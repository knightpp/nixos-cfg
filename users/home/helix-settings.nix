{
  theme = "gruvbox";
  editor = {
    cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };

    middle-click-paste = false;
    auto-save = true;
    text-width = 100;

    lsp = {
      display-messages = true;
      # display-inlay-hints = true; # didn't work with Go
    };

    indent-guides = {
      render = true;
      character = "╎"; # Some characters that work well: "▏", "┆", "┊", "⸽"
      skip-levels = 1;
    };

    soft-wrap = {
      enable = true;
      # max-wrap = 25; # increase value to reduce forced mid-word wrapping
      # max-indent-retain = 0;
    };
  };
  # Colemak DH helix keys
  keys = {
    normal = {
      m = "move_char_left"; # h
      n = "move_visual_line_down"; # j
      e = "move_visual_line_up"; # k
      i = "move_char_right"; # l

      h = "insert_mode";
      H = "insert_at_line_start";

      f = "move_next_word_end";
      F = "move_next_long_word_end";

      j = "search_next";
      J = "search_prev";

      g = {
        m = "goto_line_start";
        i = "goto_line_end";
      };

      # Minor Match Mode
      t = {
        t = "match_brackets";
        s = "surround_add";
        r = "surround_replace";
        d = "surround_delete";
        e = "select_textobject_around";
        n = "select_textobject_inner";
      };

      k = "join_selections";
      K = "join_selections_space";

      space.w = {
        m = "jump_view_left";
        n = "jump_view_down";
        e = "jump_view_up";
        i = "jump_view_right";
      };

      z = {
        n = "scroll_down";
        i = "scroll_up";
      };

      Z = {
        n = "scroll_down";
        i = "scroll_up";
      };
    };

    select = {
      m = "extend_char_left"; # h
      n = "extend_visual_line_down"; # j
      e = "extend_visual_line_up"; # k
      i = "extend_char_right"; # l

      h = "insert_mode";
      H = "insert_at_line_start";

      f = "extend_next_word_end";
      F = "extend_next_long_word_end";

      j = "extend_search_next";
      J = "extend_search_prev";

      # TODO: extract into variable?
      # Minor Match Mode
      t = {
        t = "match_brackets";
        s = "surround_add";
        r = "surround_replace";
        d = "surround_delete";
        e = "select_textobject_around";
        n = "select_textobject_inner";
      };
    };
  };
}
