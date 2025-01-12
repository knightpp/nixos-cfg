{
  theme = "gruvbox";
  editor = {
    cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };

    # see https://helix-editor.com/news/release-25-01-highlights/
    end-of-line-diagnostics = "hint";
    inline-diagnostics = {
      cursor-line = "hint";
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
  keys = let
    minorMatchMode = {
      t = "match_brackets";
      s = "surround_add";
      r = "surround_replace";
      d = "surround_delete";
      e = "select_textobject_around";
      n = "select_textobject_inner";
    };
  in {
    normal = {
      m = "move_char_left"; # h
      n = "move_visual_line_down"; # j
      e = "move_visual_line_up"; # k
      i = "move_char_right"; # l

      N = "add_newline_below";
      E = "add_newline_above";

      h = "insert_mode";
      H = "insert_at_line_start";

      f = "move_next_word_end";
      F = "move_next_long_word_end";

      j = "search_next";
      J = "search_prev";

      l = "extend_search_next";
      L = "extend_search_prev";

      g = {
        m = "goto_first_nonwhitespace";
        M = "goto_line_start";
        i = "goto_line_end";
        n = "goto_last_line";
        e = "goto_file_start";

        l = "goto_next_buffer";
        u = "goto_previous_buffer";

        t = "goto_type_definition";
        s = "goto_implementation";

        w = "no_op";
        y = "no_op";
        k = "no_op";
        j = "no_op";
        c = "no_op";
        b = "no_op";
        h = "no_op";
        p = "no_op";
      };

      t = minorMatchMode;

      k = "join_selections";
      K = "join_selections_space";

      space = {
        F = "file_picker_in_current_buffer_directory";
        w = {
          m = "jump_view_left";
          n = "jump_view_down";
          e = "jump_view_up";
          i = "jump_view_right";
        };
      };

      x = "extend_line_below";
      X = "extend_line_above";
      T = "extend_line_below";
      S = "extend_line_above";

      z = {
        c = "no_op";
        b = "no_op";
        i = "no_op";
        k = "no_op";
        j = "no_op";
        up = "no_op";
        down = "no_op";
        C-u = "no_op";
        C-d = "no_op";

        s = "align_view_top";
        t = "align_view_bottom";
        g = "align_view_middle";
        r = "align_view_middle";

        n = "page_down";
        e = "page_up";
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

      t = minorMatchMode;

      g = {
        m = "goto_first_nonwhitespace";
        M = "goto_line_start";
        i = "goto_line_end";
        n = "goto_last_line";
        e = "goto_file_start";
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
