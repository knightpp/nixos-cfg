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
      display-inlay-hints = true;
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

      l = "no_op";

      h = "insert_mode";
      H = "insert_at_line_start";

      f = "move_next_word_end";
      F = "move_next_long_word_end";

      j = "search_next";
      J = "search_prev";

      g = {
        m = "goto_first_nonwhitespace";
        M = "goto_line_start";
        i = "goto_line_end";
        n = "goto_last_line";
        e = "goto_file_start";

        l = "goto_next_buffer";
        u = "goto_previous_buffer";

        t = "goto_type_definition";

        w = "no_op";
        y = "no_op";
        s = "no_op";
        k = "no_op";
        j = "no_op";
        c = "no_op";
        b = "no_op";
        h = "no_op";
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

      # see https://github.com/helix-editor/helix/discussions/2542#discussioncomment-2959010
      # run linter/lsp on ESC
      # esc = ["collapse_selection" ":u"];
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

      # run linter/lsp on ESC
      # esc = ["collapse_selection" "normal_mode" ":u"];
    };

    insert = {
      # run linter/lsp on ESC
      # esc = ["normal_mode" ":u"];
    };
  };
}
