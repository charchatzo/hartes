/*
* Copyright (c) 2020 charalabos (charchatzo2008@gmail.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: charalabos <charchatzo2008@gmail.com>
*/
using Granite;
using Granite.Widgets;
using Gtk;
using WebKit;

public class welcomeview : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.Welcome ("Deep Dive", "This is a simple web browser.");

        add (welcome);
    }
}
public class save_notes_to_file_warning : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.Welcome ("Warning!", "The file will be overwritten.");

        add (welcome);
    }
}
namespace Dive {
    public class Application : Gtk.Application {

        public Application () {
            Object(
                application_id: "com.github.Deep-dive",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }



        public override void activate () {
            var window = new Gtk.ApplicationWindow (this);
            var main_grid = new Gtk.Grid ();
            var headerbar = new Gtk.HeaderBar ();
            var searchbar = new Gtk.Entry ();
            var browser = new WebView ();
            var back = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON);
            var forward = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON);
            var reload = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.BUTTON);
            var gtk_settings = Gtk.Settings.get_default ();
            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            var switcher = new Gtk.StackSwitcher ();
            var stack = new Gtk.Stack ();
            var settings_section = new Gtk.Grid ();
            var dark_mode_label = new Gtk.Label ("Dark mode:  ");
            var custom_title_grid = new Gtk.Grid ();
            var settings = new GLib.Settings ("com.github.deep-dive");
            var save_button = new Gtk.Button.with_label ("Save settings");
            var start_page_entry = new Gtk.Entry ();
            var start_page_label = new Gtk.Label ("Default page: ");
            var default_page_set_current = new Gtk.Button.with_label ("Set current page as default");
            var set_google_default_button = new Gtk.Button.with_label ("Set Google as default");
            var set_yahoo_default_button = new Gtk.Button.with_label ("Set Yahoo as default");
            var set_duck_default_button = new Gtk.Button.with_label ("Set DuckDuckGo as default");
            var text_tag_table = new Gtk.TextTagTable ();
            var text_buffer = new Gtk.TextBuffer (text_tag_table);
            var text_view = new Gtk.TextView.with_buffer (text_buffer);
            var save_notes_to_file = new Gtk.Button.with_label ("Save to file");
            var save_notes_to_gschema = new Gtk.Button.with_label ("Save to gschema");
            var save_notes_grid = new Gtk.Grid ();
            var open_notes_from_gschema = new Gtk.Button.with_label ("Open notes from gschema");
            var open_notes_from_file = new Gtk.Button.with_label ("Open notes from file");
            var save_history_label = new Gtk.Label ("Save history:  ");
            var save_history = new Gtk.Switch ();
            var file_history = File.new_for_path (".deepdivehistory.txt");
            var searchbar_second = new Gtk.Entry ();

            searchbar_second.placeholder_text = "Search on the google.";
            searchbar_second.activate.connect (() => {
                browser.load_uri ("https://www.google.com/search?q=" + searchbar_second.text);
            });

            if (file_history.query_exists ()) {
                file_history.delete ();
            }
            var dos_history = new DataOutputStream (file_history.create (FileCreateFlags.REPLACE_DESTINATION));   
            browser.load_changed.connect (() => {
                searchbar.set_text (browser.uri);
                dos_history.put_string (browser.uri + "\n");
                window.set_title (browser.uri + " - Deep Dive");
            });

            open_notes_from_file.clicked.connect (() => {
                var notes_file = File.new_for_path ("notes.txt");
                var dis = new DataInputStream (notes_file.read());
                string line;
                while ((line = dis.read_line (null)) != null) {
                    text_buffer.set_text (text_buffer.text + line + "\n");
                }
            });

            open_notes_from_gschema.clicked.connect (() => {
                text_buffer.text = settings.get_string ("notes");
            });

            save_notes_grid.attach (save_notes_to_file, 0, 0, 10, 10);
            save_notes_grid.attach_next_to (save_notes_to_gschema, save_notes_to_file, Gtk.PositionType.RIGHT, 10, 10);

            save_notes_to_gschema.clicked.connect (() => {
               settings.set_string ("notes", text_buffer.text);
            });

            save_notes_to_file.clicked.connect (() => {
                var file = File.new_for_path ("notes.txt");
                if (file.query_exists ()) {
                    var file_exists_warning = new save_notes_to_file_warning ();
                    var file_exists_window = new Gtk.Window ();
                    file_exists_window.set_title ("Warning!");
                    file_exists_window.add (file_exists_warning);
                    file_exists_window.show_all ();
                    file.delete ();
                }
                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
                dos.put_string (text_buffer.text);
            });

            default_page_set_current.clicked.connect (() => {
                start_page_entry.text = browser.uri;
            });

            set_yahoo_default_button.clicked.connect (() => {
                start_page_entry.set_text ("https://yahoo.com");
            });

            set_duck_default_button.clicked.connect (() => {
                start_page_entry.set_text ("https://duckduckgo.com/");
            });

            start_page_entry.set_text (settings.get_string("default-page"));

            window.move (settings.get_int("pos-x"), settings.get_int("pos-y"));
            window.resize (settings.get_int("window-width"), settings.get_int("window-height"));

            custom_title_grid.attach (searchbar, 0, 0, 1, 1);
            custom_title_grid.attach_next_to (main_grid, searchbar, Gtk.PositionType.LEFT, 1, 1);
            custom_title_grid.attach_next_to (searchbar_second, searchbar, Gtk.PositionType.RIGHT, 1, 1);
            custom_title_grid.attach_next_to (reload, searchbar_second, Gtk.PositionType.RIGHT, 1, 1);

            browser.load_uri (start_page_entry.text);

            settings_section.attach (mode_switch, 0, 0, 10, 10);
            settings_section.attach_next_to (dark_mode_label, mode_switch, Gtk.PositionType.LEFT, 10, 10);
            settings_section.attach_next_to (start_page_entry, mode_switch, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (default_page_set_current, start_page_entry, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (save_button, default_page_set_current, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (set_google_default_button, save_button, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (set_yahoo_default_button, set_google_default_button, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (set_duck_default_button, set_yahoo_default_button, Gtk.PositionType.BOTTOM, 10, 10);
            settings_section.attach_next_to (start_page_label, start_page_entry, Gtk.PositionType.LEFT, 10, 10);
            settings_section.attach_next_to (open_notes_from_gschema, set_duck_default_button, Gtk.PositionType.BOTTOM  , 10 ,10);
            settings_section.attach_next_to (open_notes_from_file, open_notes_from_gschema, Gtk.PositionType.BOTTOM, 10, 10);

            switcher.stack = stack;
            stack.expand = true;
            stack.add_titled (browser, "browser_section_stacked", "Browser");
            stack.add_titled (settings_section, "settings_section_stacked", "Settings");
            stack.add_titled (text_view, "text_view_section_stacked", "Notes");

            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            var wv = new welcomeview ();
            var welcomemessage = new Gtk.Window ();


            welcomemessage.add (wv);
            welcomemessage.set_title ("About");

            main_grid.attach (back, 0, 0, 1, 1);
            main_grid.attach_next_to (forward, back, Gtk.PositionType.RIGHT, 1, 1);

            reload.clicked.connect (() => {
                browser.reload ();
            });

            searchbar.valign = Gtk.Align.CENTER;
            searchbar.set_size_request (300, 10);

            searchbar.activate.connect (() => {
                browser.load_uri (searchbar.text);
            });

            back.clicked.connect (() => {
                browser.go_back ();
            });

            forward.clicked.connect (() => {
                browser.go_forward ();
            });


            headerbar.set_show_close_button (true);
            headerbar.set_custom_title (custom_title_grid);
            headerbar.pack_end (switcher);
            headerbar.pack_start (save_notes_grid);
            window.set_titlebar (headerbar);

            save_button.clicked.connect (() => {
                int width, height, x, y;
                window.get_position (out x, out y);
                window.get_size (out width, out height);
                settings.set_int ("window-width", width);
                settings.set_int ("window-height", height);
                settings.set_int ("pos-x", x);
                settings.set_int ("pos-y", y);
                settings.set_string ("default-page", start_page_entry.text);
            });
            
            window.set_default_size (900, 640);
            window.add (stack);
            window.show_all ();
            welcomemessage.show_all ();
        }

        public static int main (string[] args) {
            var app = new Dive.Application ();
            return app.run (args);
        }
    }
}