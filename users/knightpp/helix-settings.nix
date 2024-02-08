{
  theme = "gruvbox";
  editor.cursor-shape = {
    insert = "bar";
    normal = "block";
    select = "underline";
  };
  # Colemak DH helix keys
  keys = {
    normal = {
      m = "move_char_left";
      n = "move_line_down";
      e = "move_line_up";
      i = "move_char_right";

      h = "insert_mode";
      H = "insert_at_line_start";

      l = "open_below";
      L = "open_above";

      f = "move_next_word_end";
      F = "move_next_long_word_end";

      j = "search_next";
      J = "search_prev";

      g = {
        n = "goto_line_start";
        o = "goto_line_end";
      };

      space.w = {
        m = "jump_view_left";
        n = "jump_view_down";
        e = "jump_view_up";
        i = "jump_view_right";
      };

      "C-w" = {
        m = "jump_view_left";
        n = "jump_view_down";
        E = "join_selections";
        "A-E" = "join_selections_space";
        e = "jump_view_up";
        I = "keep_selections";
        "A-I" = "remove_selections";
        i = "jump_view_right";
      };

      z = {
        e = "scroll_down";
        i = "scroll_up";
      };

      Z = {
        e = "scroll_down";
        i = "scroll_up";
      };
    };

    select = {
      m = "move_char_left";
      n = "move_line_down";
      e = "move_line_up";
      i = "move_char_right";
      h = "insert_mode";
      H = "insert_at_line_start";
      l = "open_below";
      L = "open_above";
      f = "move_next_word_end";
      F = "move_next_long_word_end";
      j = "search_next";
      k = "search_prev";
    };
  };
}
