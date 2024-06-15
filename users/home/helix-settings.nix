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
        n = "scroll_down";
        i = "scroll_up";
      };

      Z = {
        n = "scroll_down";
        i = "scroll_up";
      };
    };

    select = {
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
    };
  };
}
