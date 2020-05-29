/*
* Copyright (c) {{yearrange}} charalabos ()
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
* Authored by: charalabos <>
*/
using Granite;
using Granite.Widgets;
using Gtk;
using WebKit;

public class welcomeview : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.Welcome ("Deep Dive", "This is a simple web browser.");

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    try {
                        AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
                case 1:
                    try {
                        AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
                    } catch (Error e) {
                        warning (e.message);
                    }

                    break;
            }
        });
    }
}


namespace Dive {
    public class Application : Granite.Application {

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
            var save_notes = new Gtk.Button.with_label ("Save notes");

            text_buffer.text = settings.get_string ("notes");

            save_notes.clicked.connect (() => {
                settings.set_string ("notes", text_buffer.text);
            });

            default_page_set_current.clicked.connect (() => {
                start_page_entry.text = browser.get_uri ();
            });

            set_google_default_button.clicked.connect (() => {
                start_page_entry.set_text ("https://google.com");
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
            custom_title_grid.attach_next_to (reload, searchbar, Gtk.PositionType.RIGHT, 1, 1);
            custom_title_grid.attach_next_to (main_grid, searchbar, Gtk.PositionType.LEFT, 1, 1);

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
            searchbar.set_size_request (500, 10);

            browser.load_changed.connect (() => {
                searchbar.set_text (browser.uri);
            });

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
            headerbar.pack_start (save_notes);
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